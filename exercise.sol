// SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

interface IERC20 {
    // 标准ERC20接口
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract MyToken is IERC20 {
    // 代币基本信息
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    // 所有权和权限控制
    address private _owner;
    
    // 代币状态变量
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // 扩展功能状态
    mapping(address => bool) private _blacklist;
    bool private _paused;
    
    // 事件定义
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed account, uint256 amount);
    event BlacklistUpdated(address indexed account, bool isBlacklisted);
    event PauseStatusChanged(bool isPaused);
    
    // 构造函数应初始化代币名称、符号、小数位和初始所有者
    constructor(string memory name , string memory symbol , uint8 decimals){
        _owner = msg.sender;
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _balances[msg.sender] += _totalSupply *(10 **_decimals);
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // modifier定义
    modifier onlyOwner() {
        require(msg.sender == _owner,"Invalid address");
        _;
    }
    
    modifier notPaused() {
    require(!_paused, "Token: all transfers are paused");
        _;
    }
    
    modifier notBlacklisted(address account) {
        require(_blacklist[account] != true,"this addr is blacked");
        _;
    }
        // 实现所有要求的函数...
    function pause() external onlyOwner{
        _paused = true;
        emit PauseStatusChanged(true);
    }
    function unpause() external onlyOwner{
        _paused = false;
        emit PauseStatusChanged(false);
    }
    function paused() external view returns (bool){
        return _paused;
    }

    function totalSupply() external view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256){
        require(account != address(0),"invalid addr");
        return _balances[account];
    }

    function addToBlacklist(address account) external onlyOwner{
        require(account != address(0),"invalid accr");
        _blacklist[account] = true;
        emit BlacklistUpdated(account, true);
    }
    function removeFromBlacklist(address account) external onlyOwner{
        require(account != address(0),"invalid accr");
        _blacklist[account] = false;
        emit BlacklistUpdated(account, false);
    }
    function isBlacklisted(address account) external view returns (bool){
        require(account != address(0),"invalid accr");
        return _blacklist[account];
    }

    function transfer(address recipient, uint256 amount) 
    external notPaused notBlacklisted(recipient) notBlacklisted(msg.sender)returns(bool){
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
     external notBlacklisted(msg.sender) notBlacklisted(spender) notPaused returns (bool){
        require(spender != address(0),"Invalid addr");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
     }

    function allowance(address owner, address spender) external view returns (uint256){
        require(_allowances[owner][spender] != 0,"zero");
        return _allowances[owner][spender];
    }
    function transferFrom(address sender, address recipient, uint256 amount) 
    external notBlacklisted(sender) notBlacklisted(recipient) notPaused returns (bool){
        require(_allowances[sender][msg.sender] >= amount,"balance not enough");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function exercise()external view returns(uint){}
}
