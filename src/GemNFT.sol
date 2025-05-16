// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "src/RulesEngineGemNFTIntegration.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GemNFT is RulesEngineClientCustom, ERC721, ERC721Enumerable, Ownable {
    uint256 private _nextId = 1;
    mapping(uint256 => address) private _owners;
    mapping(uint256 => string) private _uris;
    mapping(uint256 => Appraisal[]) private _appraisals;
    mapping(uint256 => bool) private _burned;

    address public immutable ZERO_ADDRESS = address(0);

    struct Appraisal {
        uint128 number;
        uint128 value;
        string doc;
        uint128 date;
    }

    struct TokenData {
        uint256 id;
        string uri;
        Appraisal[] appraisals;
    }

    event TokenAppraised(uint256 indexed id, uint128 value);
    event TokenBurned(uint256 indexed id);
    event URISet(uint256 indexed id, string uri);

    error NotExists();
    error InvalidValue();
    error NoAppraisals();
    error ZeroAddress();
    error ZeroValue();
    error TransferNotAllowed();

    constructor() ERC721("GemNFT", "GEM") Ownable(msg.sender) {}

    // Custom methods
    function mint(
        string calldata uri,
        uint128 number,
        uint128 value,
        string calldata doc,
        uint128 date
    ) external onlyOwner {
        uint256 id = _nextId++;
        _safeMint(msg.sender, id);
        _owners[id] = msg.sender;
        _setTokenURI(id, uri);
        _appraise(id, number, value, doc, date);
    }

    function burn(uint256 id) external onlyOwner {
        if (!_exists(id)) revert NotExists();

        _burned[id] = true;
        _burn(id);

        emit TokenBurned(id);
    }

    function tokenURI(
        uint256 id
    ) public view virtual override returns (string memory) {
        if (!_exists(id)) revert NotExists();
        return _uris[id];
    }

    function appraise(
        uint256 id,
        uint128 number,
        uint128 value,
        string calldata doc,
        uint128 date
    ) external onlyOwner {
        _appraise(id, number, value, doc, date);
    }

    function appraisals(uint256 id) public view returns (Appraisal[] memory) {
        if (!_exists(id)) revert NotExists();

        return _appraisals[id];
    }
    
    function lastAppraisal(
        uint256 id
    ) public view returns (uint128, uint128, string memory, uint128) {
        if (!_exists(id)) revert NotExists();
        uint256 len = _appraisals[id].length;
        if (len == 0) revert NoAppraisals();

        Appraisal memory last = _appraisals[id][len - 1];
        return (last.number, last.value, last.doc, last.date);
    }

    function listAll() public view returns (TokenData[] memory) {
        uint256 total = 0;
        uint256 maxId = _nextId - 1;

        for (uint256 i = 1; i <= maxId; i++) {
            if (_exists(i)) total++;
        }

        if (total == 0) revert ZeroValue();

        TokenData[] memory tokens = new TokenData[](total);
        uint256 idx = 0;

        for (uint256 i = 1; i <= maxId; i++) {
            if (_exists(i)) {
                tokens[idx] = TokenData({
                    id: i,
                    uri: tokenURI(i),
                    appraisals: _appraisals[i]
                });
                idx++;
            }
        }

        return tokens;
    }

    function listByOwner(
        address owner
    ) public view returns (TokenData[] memory) {
        uint256 balance = balanceOf(owner);
        if (balance == 0) revert ZeroValue();

        TokenData[] memory tokens = new TokenData[](balance);
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(owner, i);
            tokens[i] = TokenData({
                id: tokenId,
                uri: tokenURI(tokenId),
                appraisals: _appraisals[tokenId]
            });
        }

        return tokens;
    }

    // Private helper methods
    function _exists(uint256 id) internal view returns (bool) {
        return _owners[id] != ZERO_ADDRESS && !_burned[id];
    }

    function _setTokenURI(uint256 id, string calldata uri) internal {
        _uris[id] = uri;
        emit URISet(id, uri);
    }

    function _appraise(
        uint256 id,
        uint128 number,
        uint128 value,
        string calldata doc,
        uint128 date
    ) internal {
        if (value == 0) revert InvalidValue();

        _appraisals[id].push(
            Appraisal({number: number, value: value, doc: doc, date: date})
        );
        emit TokenAppraised(id, value);
    }

    // Override _update to prevent transfers
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        // Only allow minting (when auth is address(0))
        if (auth != address(0)) revert TransferNotAllowed();
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}