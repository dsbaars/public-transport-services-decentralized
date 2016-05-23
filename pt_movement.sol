// This is a first attempt to translate the Dutch OV-chipkaart
// system to a smart contract based system.
//
// This could be a first step in cross-border public transportation
// using shared infrastructure, the Ethereum blockchain
//
// It is dependent on Oracles which inject public transportation movements
// on the blockchain
contract PublicTransportAction
{
	struct Checkpoint {
		uint time;
		uint location;
		uint agency;
	}

	address public traveller;
	uint numCheckpoints;
	uint[] agencies;
	uint[] times;
	enum State { CheckedIn, CheckedOut }
	State public state;

	mapping(uint => Checkpoint) public checkpoints;

	event checkedIn();
	event checkedOut();
	event transferred();

	modifier inState(State _state) {
        if (state != _state) throw;
        _
    }

	function PublicTransportAction(uint _loc, uint _agency) {
		traveller = msg.sender;

		checkpoints[0] = Checkpoint(now, _loc, _agency);
		numCheckpoints = 1;

		state = State.CheckedIn;
		checkedIn();
	}

	modifier onlyTraveller() {
        if (msg.sender != traveller) throw;
        _
    }

	function transfer(uint _loc, uint _agency)
		onlyTraveller()
		inState(State.CheckedIn)
	{
		traveller = msg.sender;

		checkpoints[numCheckpoints] = Checkpoint(now, _loc, _agency);
		numCheckpoints++;

		transferred();
	}


	function checkOut(uint _loc, uint _agency)
		onlyTraveller()
		inState(State.CheckedIn)
	{
		checkpoints[numCheckpoints] = Checkpoint(now, _loc, _agency);
		state = State.CheckedOut;

		agencies = new uint[](numCheckpoints + 1);
		times = new uint[](numCheckpoints + 1);

		for(uint i=0;i<=numCheckpoints;i++)
   		 {
      	  agencies[i] = checkpoints[i].agency;
	      times[i] = checkpoints[i].time;
    	}

		checkedOut();
	}
}
