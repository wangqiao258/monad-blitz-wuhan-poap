// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/// @title Monad Blitz Wuhan 2026 - Proof of Attendance (POAP)
/// @notice 链上出席证明 NFT。证书边框与文字由合约生成；领取者可上传一张自己的图片，
///         该图片会被嵌入到链上生成的证书中作为主视觉。不传图则使用默认链上样式。
contract AttendancePOAP is ERC721, Ownable {
    using Strings for uint256;

    string public eventName = "Monad Blitz Wuhan 2026";
    string public eventDate = "2026-07-25";
    string public eventCity = "Wuhan";

    uint256 public nextId = 1;
    uint256 public claimStart;
    uint256 public claimEnd;

    /// @notice 单张上传图片的最大字节数（限制链上存储与 gas）。
    uint256 public constant MAX_IMAGE_BYTES = 120000;

    mapping(address => bool) public hasClaimed;
    mapping(uint256 => uint256) public mintedAt;
    /// @notice tokenId => 用户上传图片的 data URI（如 "data:image/jpeg;base64,...")；为空则用默认样式。
    mapping(uint256 => string) public tokenImage;

    event Claimed(address indexed attendee, uint256 indexed tokenId, uint256 timestamp, bool customImage);

    constructor() ERC721("Monad Blitz Wuhan 2026 POAP", "MBWH26") Ownable(msg.sender) {
        claimStart = block.timestamp;
        claimEnd = block.timestamp + 24 hours;
    }

    /// @notice 领取一枚出席证明（默认链上样式，不含自定义图片）。
    function mint() external {
        _claim("");
    }

    /// @notice 领取一枚出席证明，并嵌入领取者上传的图片。
    /// @param imageDataURI 完整的图片 data URI，例如 "data:image/jpeg;base64,/9j/..."。
    function mintWithImage(string calldata imageDataURI) external {
        require(bytes(imageDataURI).length <= MAX_IMAGE_BYTES, "Image too large");
        _claim(imageDataURI);
    }

    function _claim(string memory imageDataURI) internal {
        require(block.timestamp >= claimStart, "Claim not started");
        require(block.timestamp <= claimEnd, "Claim closed");
        require(!hasClaimed[msg.sender], "Already claimed");

        uint256 tokenId = nextId++;
        hasClaimed[msg.sender] = true;
        mintedAt[tokenId] = block.timestamp;

        bool hasCustom = bytes(imageDataURI).length > 0;
        if (hasCustom) {
            tokenImage[tokenId] = imageDataURI;
        }

        _safeMint(msg.sender, tokenId);
        emit Claimed(msg.sender, tokenId, block.timestamp, hasCustom);
    }

    /// @notice owner 调整领取窗口（保证演示时一定可领）。
    function setClaimWindow(uint256 _start, uint256 _end) external onlyOwner {
        require(_end > _start, "end must be > start");
        claimStart = _start;
        claimEnd = _end;
    }

    /// @notice 当前是否处于可领取窗口。
    function isClaimOpen() external view returns (bool) {
        return block.timestamp >= claimStart && block.timestamp <= claimEnd;
    }

    function totalMinted() external view returns (uint256) {
        return nextId - 1;
    }

    function _shortAddr(address a) internal pure returns (string memory) {
        bytes memory full = bytes(Strings.toHexString(uint160(a), 20));
        bytes memory out = new bytes(13);
        for (uint256 i = 0; i < 6; i++) out[i] = full[i];
        out[6] = ".";
        out[7] = ".";
        out[8] = ".";
        for (uint256 i = 0; i < 4; i++) out[9 + i] = full[38 + i];
        return string(out);
    }

    /// @notice 证书主视觉区域：有自定义图则圆形裁切嵌入用户图片，否则画默认徽章。
    function _visual(uint256 tokenId) internal view returns (string memory) {
        string memory img = tokenImage[tokenId];
        if (bytes(img).length > 0) {
            return string(
                abi.encodePacked(
                    '<defs><clipPath id="c"><circle cx="240" cy="130" r="66"/></clipPath></defs>',
                    '<image x="174" y="64" width="132" height="132" clip-path="url(#c)" ',
                    'preserveAspectRatio="xMidYMid slice" href="', img, '"/>',
                    '<circle cx="240" cy="130" r="66" fill="none" stroke="#836EF9" stroke-width="4"/>'
                )
            );
        }
        return string(
            abi.encodePacked(
                '<circle cx="240" cy="130" r="46" fill="none" stroke="#836EF9" stroke-width="4"/>',
                '<circle cx="240" cy="130" r="22" fill="#836EF9"/>'
            )
        );
    }

    function _buildSVG(uint256 tokenId, address holder) internal view returns (string memory) {
        return string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" width="480" height="480" viewBox="0 0 480 480">',
                '<defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">',
                '<stop offset="0" stop-color="#200052"/><stop offset="1" stop-color="#0E100F"/>',
                '</linearGradient></defs>',
                '<rect width="480" height="480" fill="url(#bg)"/>',
                '<rect x="20" y="20" width="440" height="440" rx="24" fill="none" stroke="#836EF9" stroke-width="2"/>',
                _visual(tokenId),
                '<text x="240" y="235" fill="#FBFAF9" font-family="Arial,sans-serif" font-size="15" letter-spacing="3" text-anchor="middle">PROOF OF ATTENDANCE</text>',
                '<text x="240" y="272" fill="#FBFAF9" font-family="Arial,sans-serif" font-size="26" font-weight="bold" text-anchor="middle">Monad Blitz Wuhan</text>',
                '<text x="240" y="304" fill="#836EF9" font-family="Arial,sans-serif" font-size="20" font-weight="bold" text-anchor="middle">2026-07-25</text>',
                '<text x="240" y="362" fill="#A0A0B8" font-family="monospace" font-size="16" text-anchor="middle">',
                _shortAddr(holder),
                '</text>',
                '<text x="240" y="408" fill="#836EF9" font-family="Arial,sans-serif" font-size="30" font-weight="bold" text-anchor="middle">#',
                tokenId.toString(),
                '</text>',
                '<text x="240" y="440" fill="#6B6B80" font-family="Arial,sans-serif" font-size="12" letter-spacing="2" text-anchor="middle">MONAD TESTNET</text>',
                '</svg>'
            )
        );
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        address holder = ownerOf(tokenId);
        string memory svg = _buildSVG(tokenId, holder);
        string memory image = string(
            abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(bytes(svg)))
        );

        string memory json = string(
            abi.encodePacked(
                '{"name":"', eventName, ' #', tokenId.toString(),
                '","description":"Proof of Attendance for ', eventName,
                ' held on ', eventDate, ' in ', eventCity,
                '. Fully on-chain, generated by the contract.',
                '","attributes":[',
                '{"trait_type":"Event","value":"', eventName, '"},',
                '{"trait_type":"Date","value":"', eventDate, '"},',
                '{"trait_type":"City","value":"', eventCity, '"},',
                '{"trait_type":"Token ID","value":"', tokenId.toString(), '"}',
                '],"image":"', image, '"}'
            )
        );

        return string(
            abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json)))
        );
    }
}
