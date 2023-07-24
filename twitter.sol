// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract twitter{
    struct Tweet{
        uint id;
        address author;
        string content;
        uint createdAt;
    }
    struct Message {
        uint id;
        string content;
        address to;
        address from;
        uint createdAt;
    }
    mapping(uint=>Tweet) public tweets;
    mapping (address=>uint[]) public tweetsOf;
    mapping (address=>Message[])public conversations;
    mapping (address=>mapping(address=>bool)) public operators;
    mapping(address=>address[]) public  following;

    uint nextId;
    uint nextMessageId;
    //
    function _tweet(address _from,string memory _content) public{
        require(msg.sender == _from,"Not authorized");
        tweets[nextId] =Tweet(nextId,_from,_content,block.timestamp);
        tweetsOf[_from].push(nextId);
        nextId=nextId+1;
    }

    function _sendMessage(address _from,address _to,string memory _content)public {
        conversations[_from].push(Message(nextMessageId,_content,_to,_from,block.timestamp));
        nextMessageId =nextMessageId + 1;
    }
    //if you are tweeting
    function tweet(string memory _content)public{
        _tweet(msg.sender,_content);
    }
    //if someone is messaging behalf of you
    function tweet(address _from,string memory _content)public{
        _tweet(_from,_content);
    }
    //if you are tweeting :owner
    function sendMessage(address _to,string memory _content) public{
        require(msg.sender == _to);
        _sendMessage(msg.sender, _to, _content);
    }
    //if someone is messaging behalf of you : behalf of owner
    function sendMessage(address _from,address _to,string memory _content) public{
        _sendMessage(_from, _to, _content);
    }
    function follow(address _followed)public {
        following[msg.sender].push(_followed);
    }
    function allow(address _operator)public {
        operators[msg.sender][_operator]=true;
    }
    function disAllow(address _operator)public {
        operators[msg.sender][_operator]=false;
    }
    function getLatestTweet(uint count)public view  returns(Tweet[] memory){
        require(count>0 && count<=nextId,"Count is not proper");
        //creating array of Tweet struct
        Tweet[] memory _tweets = new Tweet[](count);

        uint j;
        for(uint i=nextId-count;i<=nextId;i++){
                //struct of stoarge variable to store mapping of tweet into tweets[i]
                Tweet storage _structure = tweets[i];
                //copying the data of tweet into the tweets array we created above becz we cannot acess mapping inside a function
                _tweets[j]=Tweet(_structure.id,
                _structure.author,
                _structure.content,
                _structure.createdAt
                );
                j++;
        }
        return _tweets;
    }

    function getUsertweets(address _user,uint count)public view returns(Tweet[] memory){
        Tweet[] memory _tweets= new Tweet[](count) ;//_tweets is temp memory array of length count.
        uint[] memory ids = tweetsOf[_user]; //ids is an array
        require(count>0 && count <=ids.length,"Count is not valid");

        uint j;
        for(uint i=ids.length-count;i<ids.length;i++){
            Tweet storage _structure = tweets[ids[i]];
            _tweets[j]=Tweet(_structure.id,
            _structure.author,
            _structure.content,
            _structure.createdAt
            );
            j=j+1;

        }
        return _tweets;
    }
    
}
