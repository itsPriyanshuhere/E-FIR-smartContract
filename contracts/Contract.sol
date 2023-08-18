//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Complaint{
    address public officer;
    address public owner;
    uint256 public Id;
    uint256 [] public pending;
    uint256 [] public pendingResolutions;
    uint256 [] public solved;

    constructor(address _officer){
        owner = msg.sender;
        officer = _officer;
        Id = 1;
    }

    modifier onlyOwner(){
        require(msg.sender==owner,"You are not the owner");
        _;
    }

    modifier onlyOfficer(){
        require(msg.sender==officer,"You are not the officer");
        _;
    }

    struct complaintOfVictim{
        uint256 id;
        address complaintRegisterdBy;
        string heading;
        string description;
        string approvalStatement; //after complaint is approved
        string resolutionStatement; //after case is solved
        bool approve;
        bool resolve;
        bool exist;
    }

    event Complaintregistered(uint256 id, address complaintRegisterdBy,
    string heading);

    mapping (uint256=> complaintOfVictim) public complaintVictim;

    function fileCase(string memory _heading, string memory _description) public {
        complaintOfVictim storage newComplaint = complaintVictim[Id];
        newComplaint.id = Id;
        newComplaint.complaintRegisterdBy = msg.sender;
        newComplaint.heading = _heading;
        newComplaint.description = _description;
        newComplaint.approvalStatement = "still pending";
        newComplaint.resolutionStatement = "still pending";
        newComplaint.approve = false;
        newComplaint.resolve = false;
        newComplaint.exist = true;
        emit Complaintregistered(Id, msg.sender, _heading);
        Id++;
    }

    function deny(uint256 _id, string memory _disapprovalStatement) public onlyOfficer{
        require(complaintVictim[_id].exist == true, "This id does not exist");
        require(complaintVictim[_id].approve == false,"Already approved");
    // complaintVictim[_id].approve = false;
    complaintVictim[_id].exist = false;
    complaintVictim[_id].approvalStatement = _disapprovalStatement;
    }

    function approveComplaint(uint256 _id,string memory _approvalStatement) public onlyOfficer{
        require(complaintVictim[_id].exist == true, "This id does not exist");
        require(complaintVictim[_id].approve == false,"Already approved");
    complaintVictim[_id].approve = true;
    complaintVictim[_id].approvalStatement = _approvalStatement;
    }

    function resolveComplaint(uint256 _id, string memory _resolutionStatement) public onlyOfficer{
        require(complaintVictim[_id].exist == true, "This id does not exist");
        require(complaintVictim[_id].approve == true,"Still not approved");
        require(complaintVictim[_id].resolve == false,"Already resolved");
    complaintVictim[_id].resolve = true;
    complaintVictim[_id].resolutionStatement = _resolutionStatement;
    }

    function pendingApprovals() public{
        delete pending;
        for(uint256 i=1;i<Id;i++){
            if(complaintVictim[i].approve == false && complaintVictim[i].exist == true){
                pending.push(complaintVictim[i].id);
            }
        }
    }

    function ResolutionsLeft() public{
        delete  pendingResolutions;
        for(uint256 i=1;i<Id;i++){
            if(complaintVictim[i].resolve == false && complaintVictim[i].approve == true
             &&complaintVictim[i].exist == true){
                pendingResolutions.push(complaintVictim[i].id);
            }
        }
    }

    function solvedCases() public{
        delete  solved;
        for(uint256 i=1;i<Id;i++){
            if(complaintVictim[i].resolve == true){
                solved.push(complaintVictim[i].id);
            }
        }
    }

    function setOfficer(address _officer) public onlyOwner{
        owner = _officer;
    }

}
