pragma solidity ^0.8.0;

import "./AnonymiceLibrary.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Circles is ERC721Enumerable, Ownable {
    using AnonymiceLibrary for uint8;

    struct Trait {
        string traitName;
        string traitType;
    }

    //Mappings
    mapping(uint256 => Trait[]) public traitTypes;
    mapping(string => bool) hashToMinted;
    mapping(uint256 => string) internal tokenIdToHash;

    //uint256s
    uint256 MAX_SUPPLY = 500;
    uint256 SEED_NONCE = 0;

    //minting flag
    bool public MINTING_LIVE = false;
    uint256 public finalBlock;

    //uint arrays
    uint16[][2] TIERS;

    //p5js url
    string p5jsUrl;
    string p5jsIntegrity;
    string imageUrl;

    constructor() ERC721("Circles", "CIRC") {
        //Declare all the rarity tiers

        //Palette
        TIERS[0] = [500, 500, 500, 500, 1000, 1000, 1000, 1500, 1500, 2000];
        //Border
        TIERS[1] = [1000, 1000, 1000, 1500, 1500, 2000, 2000];
    }

    /*
  __  __ _     _   _             ___             _   _             
 |  \/  (_)_ _| |_(_)_ _  __ _  | __|  _ _ _  __| |_(_)___ _ _  ___
 | |\/| | | ' \  _| | ' \/ _` | | _| || | ' \/ _|  _| / _ \ ' \(_-<
 |_|  |_|_|_||_\__|_|_||_\__, | |_| \_,_|_||_\__|\__|_\___/_||_/__/
                         |___/                                     
   */

    /**
     * @dev Converts a digit from 0 - 10000 into its corresponding rarity based on the given rarity tier.
     * @param _randinput The input from 0 - 10000 to use for rarity gen.
     * @param _rarityTier The tier to use.
     */
    function rarityGen(uint256 _randinput, uint8 _rarityTier)
        internal
        view
        returns (uint8)
    {
        uint16 currentLowerBound = 0;
        for (uint8 i = 0; i < TIERS[_rarityTier].length; i++) {
            uint16 thisPercentage = TIERS[_rarityTier][i];
            if (
                _randinput >= currentLowerBound &&
                _randinput < currentLowerBound + thisPercentage
            ) return i;
            currentLowerBound = currentLowerBound + thisPercentage;
        }

        revert();
    }

    /**
     * @dev Generates a 11 digit hash from a tokenId, address, and random number.
     * @param _t The token id to be used within the hash.
     * @param _a The address to be used within the hash.
     * @param _c The custom nonce to be used within the hash.
     */
    function hash(
        uint256 _t,
        address _a,
        uint256 _c
    ) internal returns (string memory) {
        require(_c < 11);

        // This will generate a 11 character string.
        // The first 2 digits are the palette.
        string memory currentHash = "";

        for (uint8 i = 0; i < 10; i++) {
            SEED_NONCE++;
            uint16 _randinput = uint16(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            block.timestamp,
                            block.difficulty,
                            _t,
                            _a,
                            _c,
                            SEED_NONCE
                        )
                    )
                ) % 10000
            );

            if (i == 0) {
                uint8 rar = rarityGen(_randinput, i);
                if (rar > 9) {
                    currentHash = string(
                        abi.encodePacked(currentHash, rar.toString())
                    );
                } else {
                    currentHash = string(
                        abi.encodePacked(currentHash, "0", rar.toString())
                    );
                }
            } else {
                currentHash = string(
                    abi.encodePacked(
                        currentHash,
                        rarityGen(_randinput, i).toString()
                    )
                );
            }
        }

        if (hashToMinted[currentHash]) return hash(_t, _a, _c + 1);

        return currentHash;
    }

    /**
     * @dev Mint internal, this is to avoid code duplication.
     */
    function mintInternal() internal {
        require(
            MINTING_LIVE == true || msg.sender == owner(),
            "Minting is not live."
        );
        uint256 _totalSupply = totalSupply();
        require(_totalSupply < MAX_SUPPLY);
        require(!AnonymiceLibrary.isContract(msg.sender));

        uint256 thisTokenId = _totalSupply;

        tokenIdToHash[thisTokenId] = hash(thisTokenId, msg.sender, 0);

        hashToMinted[tokenIdToHash[thisTokenId]] = true;

        _mint(msg.sender, thisTokenId);
    }

    /**
     * @dev Mints new tokens.
     */
    function mintCircle() public {
        return mintInternal();
    }

    /*
 ____     ___   ____  ___        _____  __ __  ____     __ ______  ____  ___   ____   _____
|    \   /  _] /    ||   \      |     ||  |  ||    \   /  ]      ||    |/   \ |    \ / ___/
|  D  ) /  [_ |  o  ||    \     |   __||  |  ||  _  | /  /|      | |  ||     ||  _  (   \_ 
|    / |    _]|     ||  D  |    |  |_  |  |  ||  |  |/  / |_|  |_| |  ||  O  ||  |  |\__  |
|    \ |   [_ |  _  ||     |    |   _] |  :  ||  |  /   \_  |  |   |  ||     ||  |  |/  \ |
|  .  \|     ||  |  ||     |    |  |   |     ||  |  \     | |  |   |  ||     ||  |  |\    |
|__|\_||_____||__|__||_____|    |__|    \__,_||__|__|\____| |__|  |____|\___/ |__|__| \___|
                                                                                           
*/

    /**
     * @dev Hash to HTML function
     */
    function hashToHTML(string memory _hash, uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        string memory htmlString = string(
            abi.encodePacked(
                "data:text/html,%3Chtml%3E%3Chead%3E%3Cscript%20src%3D%22",
                p5jsUrl,
                "%22%20integrity%3D%22",
                p5jsIntegrity,
                "%22%20crossorigin%3D%22anonymous%22%3E%3C%2Fscript%3E%3C%2Fhead%3E%3Cbody%3E%3Cscript%3Evar%20tokenId%3D",
                AnonymiceLibrary.toString(_tokenId),
                "%3Bvar%20hash%3D%22",
                _hash
            )
        );

        htmlString = string(
            abi.encodePacked(
                htmlString,
                "var%20tokenId%3B%0Avar%20hash%3B%20%0A%0Aclass%20Random%20%7B%0A%20%20constructor%28%29%20%7B%0A%20%20%20%20this.useA%20%3D%20false%3B%0A%20%20%20%20let%20sfc32%20%3D%20function%20%28uint128Hex%29%20%7B%0A%20%20%20%20%20%20let%20a%20%3D%20parseInt%28uint128Hex.substr%280%2C%208%2C%2016%29%29%3B%0A%20%20%20%20%20%20let%20b%20%3D%20parseInt%28uint128Hex.substr%288%2C%208%2C%2016%29%29%3B%0A%20%20%20%20%20%20let%20c%20%3D%20parseInt%28uint128Hex.substr%2816%2C%208%2C%2016%29%29%3B%0A%20%20%20%20%20%20let%20d%20%3D%20parseInt%28uint128Hex.substr%2824%2C%208%2C%2016%29%29%3B%0A%20%20%20%20%20%20return%20function%20%28%29%20%7B%0A%20%20%20%20%20%20%20%20a%20%7C%3D%200%3B%20b%20%7C%3D%200%3B%20c%20%7C%3D%200%3B%20d%20%7C%3D%200%3B%0A%20%20%20%20%20%20%20%20var%20t%20%3D%20%28%28%28a%20%2B%20b%29%20%7C%200%29%20%2B%20d%29%20%7C%200%3B%0A%20%20%20%20%20%20%20%20d%20%3D%20%28d%20%2B%201%29%20%7C%200%3B%0A%20%20%20%20%20%20%20%20a%20%3D%20b%20%5E%20%28b%20%3E%3E%3E%209%29%3B%0A%20%20%20%20%20%20%20%20b%20%3D%20%28c%20%2B%20%28c%20%3C%3C%203%29%29%20%7C%200%3B%0A%20%20%20%20%20%20%20%20c%20%3D%20%28c%20%3C%3C%2021%29%20%7C%20%28c%20%3E%3E%3E%2011%29%3B%0A%20%20%20%20%20%20%20%20c%20%3D%20%28c%20%2B%20t%29%20%7C%200%3B%0A%20%20%20%20%20%20%20%20return%20%28t%20%3E%3E%3E%200%29%20%2F%204294967296%3B%0A%20%20%20%20%20%20%7D%3B%0A%20%20%20%20%7D%3B%0A%20%20%20%20%2F%2F%20seed%20prngA%20with%20first%20half%20of%20hash%0A%20%20%20%20this.prngA%20%3D%20new%20sfc32%28hash.substr%282%2C%2032%29%29%3B%0A%20%20%20%20%2F%2F%20seed%20prngB%20with%20second%20half%20of%20hash%0A%20%20%20%20this.prngB%20%3D%20new%20sfc32%28hash.substr%2834%2C%2032%29%29%3B%0A%20%20%20%20for%20%28let%20i%20%3D%200%3B%20i%20%3C%201e6%3B%20i%20%2B%3D%202%29%20%7B%0A%20%20%20%20%20%20this.prngA%28%29%3B%0A%20%20%20%20%20%20this.prngB%28%29%3B%0A%20%20%20%20%7D%0A%20%20%7D%0A%20%20%2F%2F%20random%20number%20between%200%20%28inclusive%29%20and%201%20%28exclusive%29%0A%20%20random_dec%28%29%20%7B%0A%20%20%20%20this.useA%20%3D%20%21this.useA%3B%0A%20%20%20%20return%20this.useA%20%3F%20this.prngA%28%29%20%3A%20this.prngB%28%29%3B%0A%20%20%7D%0A%20%20%2F%2F%20random%20number%20between%20a%20%28inclusive%29%20and%20b%20%28exclusive%29%0A%20%20random_num%28a%2C%20b%29%20%7B%0A%20%20%20%20return%20a%20%2B%20%28b%20-%20a%29%20%2A%20this.random_dec%28%29%3B%0A%20%20%7D%0A%20%20%2F%2F%20random%20integer%20between%20a%20%28inclusive%29%20and%20b%20%28inclusive%29%0A%20%20%2F%2F%20requires%20a%20%3C%20b%20for%20proper%20probability%20distribution%0A%20%20random_int%28a%2C%20b%29%20%7B%0A%20%20%20%20return%20Math.floor%28this.random_num%28a%2C%20b%20%2B%201%29%29%3B%0A%20%20%7D%0A%20%20%2F%2F%20random%20boolean%20with%20p%20as%20percent%20liklihood%20of%20true%0A%20%20random_bool%28p%29%20%7B%0A%20%20%20%20return%20this.random_dec%28%29%20%3C%20p%3B%0A%20%20%7D%0A%20%20%2F%2F%20random%20value%20in%20an%20array%20of%20items%0A%20%20random_choice%28list%29%20%7B%0A%20%20%20%20return%20list%5Bthis.random_int%280%2C%20list.length%20-%201%29%5D%3B%0A%20%20%7D%0A%7D%0A%0Alet%20mintNumber%20%3D%20parseInt%28tokenId%29%20%25%201000000%3B%0Alet%20R%20%3D%20new%20Random%28%29%3B%0A%0Alet%20w%20%3D%20window.innerWidth%3B%0Alet%20h%20%3D%20window.innerHeight%3B%20%20%0A%0Alet%20circlePalettes%20%3D%20%5B%0A%20%20%5B%27%234F3C2D%27%2C%20%27%23305E90%27%2C%20%27%23DB4E54%27%2C%20%27%23389894%27%2C%20%27%23C7E3D4%27%2C%20%27%23FFBB12%27%5D%2C%20%2F%2F0denzaclassic%0A%20%20%5B%27%234D4236%27%2C%20%27%23204973%27%2C%20%27%23F29191%27%2C%20%27%23FCD9B1%27%2C%20%27%23EBE4D8%27%2C%20%5D%2C%20%2F%2F1denzagreen%0A%20%20%5B%27%232C2933%27%2C%27%232C2933%27%2C%27%232C2933%27%2C%27%232C2933%27%2C%20%27%232C2933%27%2C%20%27%232C2933%27%2C%20%27%232C2933%27%2C%20%27%23807380%27%2C%20%27%23E6D2AC%27%2C%20%27%238FB395%27%2C%20%27%23E6918A%27%2C%20%27%233E3E59%27%5D%2C%20%2F%2F2denzadark%0A%20%20%5B%27%23ffea00%27%2C%20%27%230288E1%27%2C%20%27%23008F48%27%2C%20%27%23E93B00%27%5D%2C%20%2F%2F3twist%0A%20%20%5B%27%23F03D71%27%2C%20%27%23FE9715%27%2C%27%23F071C4%27%2C%20%27%230EACA3%27%2C%27%23E6306B%27%2C%27%23220699%27%5D%2C%20%2F%2F4super%0A%20%20%5B%27%2308DEEA%27%2C%20%27%231261D1%27%2C%27%2308DEEA%27%2C%20%27%231261D1%27%2C%20%27%23fd8090%27%5D%2C%20%2F%2F5Surfs%20Up%0A%20%20%5B%27%23111%27%2C%27%23222%27%2C%27%23333%27%2C%20%27%23444%27%2C%27%23555%27%2C%27%23666%27%2C%27%23ffd166%27%5D%2C%20%2F%2F6starry%0A%20%20%5B%27%2300A0E2%27%2C%27%230019A8%27%2C%27%23894E24%27%2C%27%23DC241F%27%2C%27%23FFCE00%27%2C%27%23868F98%27%2C%20%27%23751056%27%5D%2C%20%2F%2F7Tube%0A%20%20%5B%27%231B1B1B%27%2C%27%2300A74F%27%2C%20%27%23FFF200%27%2C%27%2300A74F%27%2C%20%27%23FFF200%27%2C%27%2300A74F%27%2C%20%27%23FFF200%27%2C%27%23ff8200%27%5D%2C%20%2F%2F8canary%0A%20%20%5B%27%23640D14%27%2C%27%23640D14%27%2C%27%23414833%27%2C%27%23656D4A%27%2C%27%23A68A64%27%2C%20%27%23A68A64%27%2C%27%23A68A64%27%5D%2C%20%2F%2F9%2794%0A%5D%3B%0Alet%20bgPalettes%20%3D%20%5B%27%23E0D8C5%27%2C%27%2366806A%27%2C%20%27%233D364D%27%2C%20%27%23FFF%27%2C%20%27%23F5E6CC%27%2C%27%23C4FFFF%27%2C%20%27%23000%27%2C%27%23FFF%27%2C%20%27%23252525%27%2C%27%23EDE0D4%27%5D%3B%0A%0Alet%20dotWeight%20%3D%20%5B%0A%20%20%5B14%2C15%2C16%2C18%2C19%2C20%2C21%2C22%2C23%2C24%2C25%2C26%2C27%2C28%2C29%2C30%2C31%2C32%5D%2C%20%2F%2F0standard%2030%25%0A%20%20%5B14%2C32%5D%2C%20%2F%2F1twos-up%2020%25%0A%20%20%5B0%2C0%2C0%2C0%2C13%2C14%2C15%2C16%2C17%2C18%2C19%2C20%2C21%2C22%2C23%2C24%2C25%2C26%2C27%2C28%2C29%2C30%2C31%2C32%5D%2C%20%2F%2F2missing%2015%25%0A%20%20%5B0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C13%2C14%2C15%2C16%2C17%2C18%2C19%2C20%2C21%2C22%2C23%2C24%2C25%2C26%2C27%2C28%2C29%2C30%2C31%2C32%5D%2C%20%2F%2F3sparce%207.5%25%0A%20%20%5B0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C13%2C14%2C15%2C16%2C17%2C18%2C19%2C20%2C21%2C22%2C23%2C24%2C25%2C26%2C27%2C28%2C29%2C30%2C31%2C32%5D%2C%20%2F%2F4absent%207.5%25%0A%20%20%5B8%2C9%2C10%2C11%2C12%2C13%2C14%2C15%2C16%2C17%2C18%2C19%2C20%2C21%2C22%5D%2C%20%2F%2F5mini%2010%25%0A%20%20%5B28%2C30%2C32%2C34%2C36%2C38%2C40%2C42%2C44%2C46%2C48%5D%20%2F%2F6maxi%201%25%0A%5D%20%0A%0Alet%20spacing%3B%0A%0Afunction%20setup%28%29%20%7B%0A%20%20paletteChoice%20%3D%20R.random_int%280%2C9%29%3B%0A%20%20canvas%20%3D%20createCanvas%28w%2Ch%29%3B%0A%20%20background%28bgPalettes%5BpaletteChoice%5D%29%3B%0A%20%20strokeWeight%280%29%3B%0A%20%20dotWeightChoice%20%3D%20R.random_int%280%2C6%29%3B%0A%20%20spaceGen%28%29%3B%0A%20%20%0A%20%20for%28let%20x%20%3D%2022%3B%20x%20%3C%20width%3B%20x%20%2B%3D%20spacing%29%20%7B%0A%20%20%20%20for%28let%20y%20%3D%2022%3B%20y%20%3C%20height%3B%20y%20%2B%3D%20spacing%29%20%7B%0A%20%20%20%20%20%20let%20size%20%3D%20R.random_choice%28dotWeight%5BdotWeightChoice%5D%29%3B%0A%20%20%20%20%20%20fill%28R.random_choice%28circlePalettes%5BpaletteChoice%5D%29%29%3B%0A%20%20%20%20%20%20ellipse%28x%2Cy%2Csize%29%3B%20%0A%20%20%20%20%7D%0A%20%20%7D%0A%20%20print%28mintNumber%29%0A%7D%0A%0Afunction%20draw%28%29%20%7B%0A%0A%7D%0A%0Afunction%20spaceGen%28%29%20%7B%0A%20%20if%20%28dotWeightChoice%20%3D%3D%205%29%20%7B%0A%20%20%20%20spacing%20%3D%2025%3B%0A%20%20%7D%20else%20if%20%28dotWeightChoice%20%3D%3D%206%29%20%7B%0A%20%20%20%20spacing%20%3D%2050%3B%0A%20%20%7D%20else%20%7B%0A%20%20%20%20spacing%20%3D%2035%3B%0A%20%20%7D%0A%7D%0A%0Afunction%20genTokenData%28projectNum%29%20%7B%0A%20%20let%20data%20%3D%20%7B%7D%3B%0A%20%20let%20hash%20%3D%20%220x%22%3B%0A%20%20for%20%28var%20i%20%3D%200%3B%20i%20%3C%2064%3B%20i%2B%2B%29%20%7B%0A%20%20%20%20hash%20%2B%3D%20%22740E8958C27C1db4C770a82E93198E2F6%22%0A%20%20%7D%0A%20%20hash%20%3D%20_hash%3B%0A%20%20tokenId%20%3D%20%28projectNum%20%2A%201000000%20%2B%20Math.floor%28Math.random%28%29%20%2A%20500%29%29.toString%28%29%3B%0A%20%20return%20data%3B%0A%7D%3C%2Fscript%3E%3C%2Fbody%3E%3C%2Fhtml%3E"
            )
        );

        return htmlString;
    }

    /**
     * @dev Hash to metadata function
     */
    function hashToMetadata(string memory _hash)
        public
        view
        returns (string memory)
    {
        string memory metadataString;

        uint8 paletteTraitIndex = AnonymiceLibrary.parseInt(
            AnonymiceLibrary.substring(_hash, 0, 2)
        );

        metadataString = string(
            abi.encodePacked(
                metadataString,
                '{"trait_type":"',
                traitTypes[0][paletteTraitIndex].traitType,
                '","value":"',
                traitTypes[0][paletteTraitIndex].traitName,
                '"},'
            )
        );

        for (uint8 i = 2; i < 11; i++) {
            uint8 thisTraitIndex = AnonymiceLibrary.parseInt(
                AnonymiceLibrary.substring(_hash, i, i + 1)
            );

            metadataString = string(
                abi.encodePacked(
                    metadataString,
                    '{"trait_type":"',
                    traitTypes[i][thisTraitIndex].traitType,
                    '","value":"',
                    traitTypes[i][thisTraitIndex].traitName,
                    '"}'
                )
            );

            if (i != 10)
                metadataString = string(abi.encodePacked(metadataString, ","));
        }

        return string(abi.encodePacked("[", metadataString, "]"));
    }

    /**
     * @dev Returns the SVG and metadata for a token Id
     * @param _tokenId The tokenId to return the SVG and metadata for.
     */
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(_tokenId));

        string memory tokenHash = _tokenIdToHash(_tokenId);

        string
            memory description = '", "description": "Circles is a collection of 500 unique pieces of generative pixel art. Metadata and art is mirrored permanently on-chain. Double click to full screen. Press F then right-click and save as a banner.",';

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    AnonymiceLibrary.encode(
                        bytes(
                            string(
                                abi.encodePacked(
                                    '{"name": "Circles #',
                                    AnonymiceLibrary.toString(_tokenId),
                                    description,
                                    '","image":"',
                                    imageUrl,
                                    AnonymiceLibrary.toString(_tokenId),
                                    '","attributes":',
                                    hashToMetadata(tokenHash),
                                    "}"
                                )
                            )
                        )
                    )
                )
            );
    }

    /**
     * @dev Returns a hash for a given tokenId
     * @param _tokenId The tokenId to return the hash for.
     */
    function _tokenIdToHash(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        string memory tokenHash = tokenIdToHash[_tokenId];

        return tokenHash;
    }

    /*

  ___   __    __  ____     ___  ____       _____  __ __  ____     __ ______  ____  ___   ____   _____
 /   \ |  |__|  ||    \   /  _]|    \     |     ||  |  ||    \   /  ]      ||    |/   \ |    \ / ___/
|     ||  |  |  ||  _  | /  [_ |  D  )    |   __||  |  ||  _  | /  /|      | |  ||     ||  _  (   \_ 
|  O  ||  |  |  ||  |  ||    _]|    /     |  |_  |  |  ||  |  |/  / |_|  |_| |  ||  O  ||  |  |\__  |
|     ||  `  '  ||  |  ||   [_ |    \     |   _] |  :  ||  |  /   \_  |  |   |  ||     ||  |  |/  \ |
|     | \      / |  |  ||     ||  .  \    |  |   |     ||  |  \     | |  |   |  ||     ||  |  |\    |
 \___/   \_/\_/  |__|__||_____||__|\_|    |__|    \__,_||__|__|\____| |__|  |____|\___/ |__|__| \___|
                                                                                                     


    */

    /**
     * @dev Clears the traits.
     */
    function clearTraits() public onlyOwner {
        for (uint256 i = 0; i < 11; i++) {
            delete traitTypes[i];
        }
    }

    /**
     * @dev Add a trait type
     * @param _traitTypeIndex The trait type index
     * @param traits Array of traits to add
     */

    function addTraitType(uint256 _traitTypeIndex, Trait[] memory traits)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < traits.length; i++) {
            traitTypes[_traitTypeIndex].push(
                Trait(traits[i].traitName, traits[i].traitType)
            );
        }

        return;
    }

    /**
     * @dev Mint for burn
     */
    function ownerMintForBurn() public onlyOwner {
        uint256 _totalSupply = totalSupply();
        require(_totalSupply < MAX_SUPPLY);
        require(!AnonymiceLibrary.isContract(msg.sender));

        uint256 thisTokenId = _totalSupply;

        tokenIdToHash[thisTokenId] = hash(thisTokenId, msg.sender, 0);

        hashToMinted[tokenIdToHash[thisTokenId]] = true;

        _mint(0x000000000000000000000000000000000000dEaD, thisTokenId);
    }

    function flipMintingSwitch() public onlyOwner {
        MINTING_LIVE = !MINTING_LIVE;
    }

    /**
     * @dev Sets the p5js url
     * @param _p5jsUrl The address of the p5js file hosted on CDN
     */

    function setJsAddress(string memory _p5jsUrl) public onlyOwner {
        p5jsUrl = _p5jsUrl;
    }

    /**
     * @dev Sets the p5js resource integrity
     * @param _p5jsIntegrity The hash of the p5js file (to protect w subresource integrity)
     */

    function setJsIntegrity(string memory _p5jsIntegrity) public onlyOwner {
        p5jsIntegrity = _p5jsIntegrity;
    }

    /**
     * @dev Sets the base image url
     * @param _imageUrl The base url for image field
     */

    function setImageUrl(string memory _imageUrl) public onlyOwner {
        imageUrl = _imageUrl;
    }
}
