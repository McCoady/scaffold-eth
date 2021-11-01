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
    uint16[][10] TIERS;

    //p5js url
    string p5jsUrl;
    string p5jsIntegrity;
    string imageUrl;

    constructor() ERC721("Circles", "CIRC") {
        //Declare all the rarity tiers

        //Palette
        TIERS[0] = [
            100,
            100,
            100,
            100,
            100,
            600,
            600,
            600,
            600,
            600,
            600,
            1000,
            1000,
            1000,
            1300,
            1600
        ];
        //Border
        TIERS[1] = [2000, 8000];
        //Number of lines
        TIERS[2] = [1000, 1000, 1000, 7000];
        //Thickness of lines
        TIERS[3] = [100, 400, 500, 9000];
        //Pixel size
        TIERS[4] = [100, 9900];
        //Noise scale
        TIERS[5] = [100, 400, 500, 9000];
        //Noise strength
        TIERS[6] = [100, 400, 500, 9000];
        //Left or right
        TIERS[7] = [5000, 5000];
        //Speed
        TIERS[8] = [1000, 9000];
        //Number of pre-iterations
        TIERS[9] = [500, 500, 1000, 1000, 7000];
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
                "%22%3Bfunction%20sdfsd%28t%29%7Breturn%20function%28%29%7Bvar%20e%3Dt%2B%3D1831565813%3Breturn%20e%3DMath.imul%28e%5Ee%3E%3E%3E15%2C1%7Ce%29%2C%28%28%28e%5E%3De%2BMath.imul%28e%5Ee%3E%3E%3E7%2C61%7Ce%29%29%5Ee%3E%3E%3E14%29%3E%3E%3E0%29%2F4294967296%7D%7Dfunction%20wraw%28t%29%7Bvar%20e%2Cr%3D%5B%5D%3Bfor%28e%3D0%3Be%3Ct.length%3Be%2B%2B%29r%5Be%5D%3Dt%5Be%5D.w1%2B%28r%5Be-1%5D%7C%7C0%29%3Bvar%20i%3Drand%28%29%2Ar%5Br.length-1%5D%3Bfor%28e%3D0%3Be%3Cr.length%26%26%21%28r%5Be%5D%3Ei%29%3Be%2B%2B%29%3Breturn%20t%5Be%5D%7Dfunction%20wrnd%28t%29%7Breturn%20wraw%28t%29.a1%7Dfunction%20gRI%28t%29%7Breturn%20Math.floor%28rand%28%29%2At%29%7Dfunction%20traitRaw%28t%2Ce%29%7Breturn%20e%3E%3Dt.length%3Ft%5Bt.length-1%5D%3At%5Be%5D%7Dfunction%20trait%28t%2Ce%29%7Breturn%20traitRaw%28t%2Ce%29.a1%7Dvar%20colors%2Cbgc%2Cc%2CdidStart%2Cimg%2Cwd%2Chei%2Cseed%2Crand%2Ctz0%2Ctz1%2Ctz2%2Ctz3%2Ctz4%2Ctz5%2Ctz6%2Ctz7%2Ctz8%2Ctz9%2Ctz10%2Cborder%2Cnum%2ClnThk%2CpxSz%2CnsScl%2CnsStr%2ClOr%2CnnUniS%2CisSUni%2Cspeed%2Czz%2Cptks%2CrunCount%2Ccanvas%2ColdWd%2ColdHei%3Bfunction%20hashToTraits%28t%29%7Bt%26%26%28tz0%3Dt.charAt%280%29%2Ctz1%3Dt.charAt%281%29%2Ctz2%3Dt.charAt%282%29%2Ctz3%3Dt.charAt%283%29%2Ctz4%3Dt.charAt%284%29%2Ctz5%3Dt.charAt%285%29%2Ctz6%3Dt.charAt%286%29%2Ctz7%3Dt.charAt%287%29%2Ctz8%3Dt.charAt%288%29%2Ctz9%3Dt.charAt%289%29%2Ctz10%3Dt.charAt%2810%29%2Ctz1%3DNumber%28tz0.toString%28%29%2Btz1.toString%28%29%29%29%7Dfunction%20setup%28%29%7Bseed%3DtokenId%2Ctz0%3D0%2Ctz1%3D7%2Ctz2%3D7%2Ctz3%3D7%2Ctz4%3D7%2Ctz5%3D7%2Ctz6%3D7%2Ctz7%3D7%2Ctz8%3D7%2Ctz9%3D7%2Ctz10%3D7%2Ctz1%3DNumber%28tz0.toString%28%29%2Btz1.toString%28%29%29%2ChashToTraits%28hash%29%2Crand%3Dsdfsd%28seed%29%2Cborder%3D0%3D%3Dtz2%3F20%3A0%3Bnum%3Dtrait%28%5B%7Ba1%3A1e3%2Cw1%3A10%7D%2C%7Ba1%3A500%2Cw1%3A10%7D%2C%7Ba1%3A250%2Cw1%3A10%7D%2C%7Ba1%3A100%2Cw1%3A70%7D%5D%2Ctz3%29%3BlnThk%3Dtrait%28%5B%7Ba1%3A40%2Cw1%3A1%7D%2C%7Ba1%3A30%2Cw1%3A4%7D%2C%7Ba1%3A10%2Cw1%3A5%7D%2C%7Ba1%3A20%2Cw1%3A90%7D%5D%2Ctz4%29%2CpxSz%3D0%3D%3Dtz5%3F20%3A10%3BnsScl%3Dtrait%28%5B%7Ba1%3A1e4%2Cw1%3A1%7D%2C%7Ba1%3A250%2Cw1%3A4%7D%2C%7Ba1%3A50%2Cw1%3A5%7D%2C%7Ba1%3A500%2Cw1%3A90%7D%5D%2Ctz6%29%3BnsStr%3Dtrait%28%5B%7Ba1%3A10%2Cw1%3A1%7D%2C%7Ba1%3A5%2Cw1%3A4%7D%2C%7Ba1%3A2%2Cw1%3A5%7D%2C%7Ba1%3A1%2Cw1%3A90%7D%5D%2Ctz7%29%2ClOr%3D0%3D%3Dtz8%3F-1%3A1%2CnnUniS%3Dfunction%28%29%7Breturn%20lOr%2A%283%2BgRI%283%29%29%7D%2Cspeed%3D%28isSUni%3D1%3D%3Dtz9%29%3F10%2AlOr%3AnnUniS%28%29%3Bzz%3Dtrait%28%5B%7Ba1%3A0%2Cw1%3A5%7D%2C%7Ba1%3A250%2Cw1%3A5%7D%2C%7Ba1%3A300%2Cw1%3A10%7D%2C%7Ba1%3A400%2Cw1%3A10%7D%2C%7Ba1%3A500%2Cw1%3A70%7D%5D%2Ctz10%29%2Cptks%3D%5Bnum%5D%2CrunCount%3D0%2Cwd%3DMath.min%28800%2CwindowWidth%29%2Chei%3DMath.min%28960%2CwindowHeight%29%2Cwd%3DMath.ceil%28wd%2FpxSz%29%2ApxSz%2Chei%3DMath.ceil%28hei%2FpxSz%29%2ApxSz%2CdidStart%3D%211%2CnoiseSeed%28seed%29%3Bvar%20t%3DtraitRaw%28%5B%7Ba1%3A%5B%28c%3Dcolor%29%28%22%23ffa4d5%22%29%2Cc%28%22%2383ffc1%22%29%2Cc%28%22%23ffe780%22%29%2Cc%28%22%2399e2ff%22%29%5D%2CbgColor%3Ac%28%22%23ffffff%22%29%2Cw1%3A1%7D%2C%7Ba1%3A%5Bc%28%22%23ffffff%22%29%2Cc%28%22%23000000%22%29%5D%2Cw1%3A1%7D%2C%7Ba1%3A%5Bc%28%22%23305e90%22%29%2Cc%28%22%23db4e54%22%29%2Cc%28%22%234f3c2d%22%29%2Cc%28%22%23ffbb12%22%29%2Cc%28%22%23389894%22%29%2Cc%28%22%23e0d8c5%22%29%2Cc%28%22%23c7e3d4%22%29%5D%2Cw1%3A1%2CbgColor%3Ac%28%22%23ffffff%22%29%7D%2C%7Ba1%3A%5Bc%28%22%230827f5%22%29%2Cc%28%22%233751f7%22%29%2Cc%28%22%238493fa%22%29%5D%2Cw1%3A1%7D%2C%7Ba1%3A%5Bc%28%22%2300c1ff%22%29%2Cc%28%22%230023ff%22%29%2Cc%28%22%237215ff%22%29%2Cc%28%22%23ff03fc%22%29%2Cc%28%22%23ff000a%22%29%2Cc%28%22%23ff8700%22%29%2Cc%28%22%23fff700%22%29%2Cc%28%22%235fff00%22%29%2Cc%28%22%2300ff2e%22%29%5D%2Cw1%3A1%2CbgColor%3Ac%28%22%23ffffff%22%29%7D%2C%7Ba1%3A%5Bc%28%22%2300e000%22%29%2Cc%28%22%23005900%22%29%2Cc%28%22%23000000%22%29%5D%2Cw1%3A5%7D%2C%7Ba1%3A%5Bc%28%22%239d0208%22%29%2Cc%28%22%23d00000%22%29%2Cc%28%22%23e85d04%22%29%2Cc%28%22%23faa307%22%29%5D%2Cw1%3A5%7D%2C%7Ba1%3A%5Bc%28%22%23fff69f%22%29%2Cc%28%22%23fdd870%22%29%2Cc%28%22%23d0902f%22%29%2Cc%28%22%23a15501%22%29%2Cc%28%22%23351409%22%29%5D%2Cw1%3A5%7D%2C%7Ba1%3A%5Bc%28%22%23a0ffe3%22%29%2Cc%28%22%2365dc98%22%29%2Cc%28%22%238d8980%22%29%2Cc%28%22%23575267%22%29%2Cc%28%22%23222035%22%29%5D%2Cw1%3A5%7D%2C%7Ba1%3A%5Bc%28%22%230099ff%22%29%2Cc%28%22%235655dd%22%29%2Cc%28%22%238822ff%22%29%2Cc%28%22%23aa99ff%22%29%5D%2Cw1%3A5%7D%2C%7Ba1%3A%5Bc%28%22%237700a6%22%29%2Cc%28%22%23fe00fe%22%29%2Cc%28%22%23defe47%22%29%2Cc%28%22%2300b3fe%22%29%2Cc%28%22%230016ee%22%29%5D%2Cw1%3A5%7D%2C%7Ba1%3A%5Bc%28%22%23c4ffff%22%29%2Cc%28%22%2308deea%22%29%2Cc%28%22%231261d1%22%29%5D%2Cw1%3A10%7D%2C%7Ba1%3A%5Bc%28%22%23ff124f%22%29%2Cc%28%22%23ff00a0%22%29%2Cc%28%22%23fe75fe%22%29%2Cc%28%22%237a04eb%22%29%2Cc%28%22%23120458%22%29%5D%2Cw1%3A10%7D%2C%7Ba1%3A%5Bc%28%22%23111111%22%29%2Cc%28%22%23222222%22%29%2Cc%28%22%23333333%22%29%2Cc%28%22%23444444%22%29%2Cc%28%22%23666666%22%29%5D%2Cw1%3A10%7D%2C%7Ba1%3A%5Bc%28%22%23f887ff%22%29%2Cc%28%22%23de004e%22%29%2Cc%28%22%23860029%22%29%2Cc%28%22%23321450%22%29%2Cc%28%22%2329132e%22%29%5D%2Cw1%3A15%7D%2C%7Ba1%3A%5Bc%28%22%238386f5%22%29%2Cc%28%22%233d43b4%22%29%2Cc%28%22%23041348%22%29%2Cc%28%22%23083e12%22%29%2Cc%28%22%231afe49%22%29%5D%2Cw1%3A20%7D%5D%2Ctz1%29%3Bcolors%3Dt.a1%2Cbgc%3Dc%28%22%23000000%22%29%2Ct.bgColor%26%26%28bgc%3Dt.bgColor%29%2C%28canvas%3DcreateCanvas%28wd%2Chei%29%29.doubleClicked%28toggleFullscreen%29%2CnoStroke%28%29%3Bfor%28let%20t%3D0%3Bt%3Cnum%3Bt%2B%2B%29%7Bvar%20e%3DcreateVector%28border%2BgRI%281.2%2A%28width-2%2Aborder%29%29%2Cborder%2BgRI%28height-2%2Aborder%29%2C2%29%2Cr%3DcreateVector%28cos%280%29%2Csin%280%29%29%3Bspeed%3DisSUni%3Fspeed%3AnnUniS%28%29%2Cptks%5Bt%5D%3Dnew%20Ptk%28e%2Cr%2Cspeed%29%7DframeRate%2810%29%7Dfunction%20remake%28t%2Ce%29%7Bt%3DMath.ceil%28t%2FpxSz%29%2ApxSz%2Ce%3DMath.ceil%28e%2FpxSz%29%2ApxSz%2Cwd%3Dt%2Chei%3De%2Cwidth%3Dt%2Cheight%3De%2C%28img%3DcreateImage%28Math.floor%28wd%2FpxSz%29%2CMath.floor%28hei%2FpxSz%29%29%29.loadPixels%28%29%2CresizeCanvas%28t%2Ce%29%3Bfor%28let%20t%3D0%3Bt%3Czz%3Bt%2B%2B%29%7Bfor%28let%20t%3D0%3Bt%3Cptks.length%3Bt%2B%2B%29ptks%5Bt%5D.run%28%29%3BrunCount%2B%2B%7D%7Dfunction%20toggleFullscreen%28%29%7Blet%20t%3Ddocument.querySelector%28%22canvas%22%29%3Bdocument.fullscreenElement%3Fdocument.exitFullscreen%28%29%3A%28oldWd%3Dwd%2ColdHei%3Dhei%2Cremake%28800%2C960%29%2Ct.requestFullscreen%28%29.catch%28t%3D%3E%7Balert%28%60Error%3A%20%24%7Bt.message%7D%20%28%24%7Bt.name%7D%29%60%29%7D%29%29%7Dfunction%20keyPressed%28%29%7Breturn%2070%3D%3D%3DkeyCode%3F%28remake%281500%2C500%29%2C%211%29%3A88%3D%3D%3DkeyCode%3F%28remake%28prompt%28%22Enter%20width%20in%20pixels%22%2C%22500%22%29%2Cprompt%28%22Height%3F%22%2C%22500%22%29%29%2C%211%29%3A79%3D%3D%3DkeyCode%3F%28toggleFullscreen%28%29%2C%211%29%3Avoid%200%7Dfunction%20draw%28%29%7Bif%28%21didStart%29%7Bfor%28let%20t%3D0%3Bt%3Czz%3Bt%2B%2B%29%7Bfor%28let%20t%3D0%3Bt%3Cptks.length%3Bt%2B%2B%29ptks%5Bt%5D.run%28%29%3BrunCount%2B%2B%7DdidStart%3D%210%7Dfor%28let%20t%3D0%3Bt%3Cptks.length%3Bt%2B%2B%29ptks%5Bt%5D.run%28%29%3BrunCount%2B%2B%2C%28img%3DcreateImage%28wd%2FpxSz%2Chei%2FpxSz%29%29.loadPixels%28%29%3Bfor%28var%20t%3D0%3Bt%3Cimg.height%3Bt%2B%2B%29for%28var%20e%3D0%3Be%3Cimg.width%3Be%2B%2B%29%7Blet%20r%3Dget%28e%2ApxSz%2Ct%2ApxSz%29%2Ci%3D4%2A%28e%2Bt%2Aimg.width%29%3Bimg.pixels%5Bi%5D%3Dred%28r%29%2Cimg.pixels%5Bi%2B1%5D%3Dgreen%28r%29%2Cimg.pixels%5Bi%2B2%5D%3Dblue%28r%29%2Cimg.pixels%5Bi%2B3%5D%3Dalpha%28r%29%7Dfill%28bgc%29%2Crect%280%2C0%2Cwidth%2Cheight%29%2Cimg.updatePixels%28%29%2CnoSmooth%28%29%2Cimage%28img%2C0%2C0%2Cwidth%2Cheight%29%2Cfill%28bgc%29%2Crect%280%2C0%2Cborder%2Cheight%29%2Crect%280%2C0%2Cwidth%2Cborder%29%2Crect%28width-border%2C0%2Cborder%2Cheight%29%2Crect%280%2Cheight-border%2Cwidth%2Cborder%29%7Dclass%20Ptk%7Bconstructor%28t%2Ce%2Cr%29%7Bthis.loc%3Dt%2Cthis.dir%3De%2Cthis.speed%3Dr%2Cthis.c%3Dcolors%5BgRI%28colors.length%29%5D%2Cthis.lineSize%3DlnThk%7Drun%28%29%7Bthis.move%28%29%2Cthis.checkEdges%28%29%2Cthis.update%28%29%7Dmove%28%29%7Blet%20t%3Dnoise%28this.loc.x%2FnsScl%2Cthis.loc.y%2FnsScl%2CrunCount%2FnsScl%29%2ATWO_PI%2AnsStr%3Bthis.dir.x%3Dcos%28t%29%2Cthis.dir.y%3Dsin%28t%29%3Bvar%20e%3Dthis.dir.copy%28%29%3Be.mult%281%2Athis.speed%29%2Cthis.loc.add%28e%29%7DcheckEdges%28%29%7B%28this.loc.x%3Cborder%7C%7Cthis.loc.x%3Ewidth-border%7C%7Cthis.loc.y%3Cborder%7C%7Cthis.loc.y%3Eheight-border%29%26%26%28this.loc.x%3Dborder%2BgRI%28width-2%2Aborder%29%2Cthis.loc.y%3Dborder%2BgRI%28height-2%2Aborder%29%29%7Dupdate%28%29%7Bfill%28this.c%29%2Cellipse%28this.loc.x%2Cthis.loc.y%2Cthis.lineSize%2Cthis.lineSize%29%7D%7D%3C%2Fscript%3E%3C%2Fbody%3E%3C%2Fhtml%3E"
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
