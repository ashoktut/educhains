// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// importing the actors and ownable
import "../educore/Ownable.sol";
import "../eduaccesscontrol/StudentRole.sol";
import "../eduaccesscontrol/UniversityRole.sol";
import "../eduaccesscontrol/AccommodationRole.sol";
import "../eduaccesscontrol/NsfasRole.sol";

// Define a contract 'EduChain'
contract EduChain is 
    Ownable,
    StudentRole,
    UniversityRole,
    AccommodationRole,
    NsfasRole
{
    // Define 'owner' and make owner payable
    address payable owner;

    // Define a variable called 'upc' for Universal Product Code (UPC) - SA ID Number
    uint256 upc;

    // Define a variable called 'sku' for Stock Keeping Unit (SKU) - Student Number
    uint256 sku;

    // Define a public mapping 'persons' that maps the UPC to a Person
    mapping(uint256 => Person) persons;

    // Define a public mapping 'personsHistory' that maps the UPC to an array of TxHash,
    // that track its journey through the educhain -- to be sent from DApp.
    mapping(uint256 => string[]) personsHistory;

    // Define enum 'State' with the following values:
    enum State {
        Applied_Uni, // 0
        Admitted, // 1
        Registered, // 2
        Applied_Accommodation, // 3
        Accepted, // 4
        Applied_Nsfas, // 5
        Approved, // 6
        Requested_BookFunds, // 7
        Paid_Books, // 8
        Requested_MonthlyFunds, // 9
        Paid_Monthly, // 10
        Requested_Rent, // 11
        Paid_Rent, // 12
        Requested_UniFees, // 13
        Paid_Fees // 14

    }

    State constant defaultState = State.Applied_Uni;

    // Define a struct 'person' with the following fields:
    struct Person {
        uint256 sku; // Stock Keeping Unit (SKU)
        uint256 upc; // Universal Product Code (UPC), Generated by the Student, goes on the package, can be verified by Nsfas
        address ownerID; // Metamask-Ethereum address of the current owner as the person moves through the states in the chain
        address originStudentID; // Metamask-Ethereum address of the Student
        string studentName; // Student Name
        string studentSurname; // Student Surname
        uint256 personID; // Person ID potentially a combination of upc + sku
        string courseName; // Course Applying for by person
        string uniName; // University that the person applying to
        uint256 bookPrice; // Book Price
        uint256 monthlyPrice; // Monthly Price
        uint256 rentPrice; // Accommodation Price
        uint256 feesPrice; // University Fees Price
        uint256 passRate; // Pass rate of the student
        State personState; // Person State as represented in the enum above
        // address studentID; // Metamask-Ethereum address of the student
        address uniID; // Metamask-Ethereum address of the University
        address accommodationID; // Metamask-Ethereum address of the Accommodation
        address nsfasID; // Metamask-Ethereum address of Nsfas
    }

    // Define 12 events with the same 12 state values and accept 'upc' as input argument
    event Applied_Uni(uint256 upc);
    event Admitted(uint256 upc);
    event Registered(uint256 upc);
    event Applied_Accommodation(uint256 upc);
    event Accepted(uint256 upc);
    event Applied_Nsfas(uint256 upc);
    event Approved(uint256 upc);
    event Requested_BookFunds(uint256 upc);
    event Paid_Books(uint256 upc);
    event Requested_MonthlyFunds(uint256 upc);
    event Paid_Monthly(uint256 upc);
    event Requested_Rent(uint256 upc);
    event Paid_Rent(uint256 upc);
    event Requested_UniFees(uint256 upc);
    event Paid_Fees(uint256 upc);
    // event Eligible(uint256 upc); ********************************************************* <----------------------Here uncomment it
    // event Graduated(uint256 upc);

    // Define a modifier that verifies the Caller
    modifier verifyCaller(address _address) {
        require(msg.sender == _address);
        _;
    }

    // Define a modifier that checks if the paid amount is sufficient to cover the books price
    modifier paidEnoughBook(uint256 _bookPrice) {
        require(msg.value >= _bookPrice);
        _;
    }

    // Define a modifier that checks the books price and refunds the remaining balance
    modifier checkBookValue(uint256 _upc) {
        _;
        uint256 _bookPrice = persons[_upc].bookPrice;
        uint256 amountToReturn = msg.value - _bookPrice;
        payable (persons[_upc].nsfasID).transfer(amountToReturn);
    }

    // Define a modifier that checks if the paid amount is sufficient to cover the price
    modifier paidEnoughMonthly(uint256 _monthlyPrice) {
        require(msg.value >= _monthlyPrice);
        _;
    }

    // Define a modifier that checks the monthly price and refunds the remaining balance
    modifier checkMonthlyValue(uint256 _upc) {
        _;
        uint256 _monthlyPrice = persons[_upc].monthlyPrice;
        uint256 amountToReturn = msg.value - _monthlyPrice;
        payable (persons[_upc].nsfasID).transfer(amountToReturn);
    }

    // Define a modifier that checks if the paid amount is sufficient to cover the price
    modifier paidEnoughRent(uint256 _rentPrice) {
        require(msg.value >= _rentPrice);
        _;
    }

    // Define a modifier that checks the rent price and refunds the remaining balance
    modifier checkRentValue(uint256 _upc) {
        _;
        uint256 _rentPrice = persons[_upc].rentPrice;
        uint256 amountToReturn = msg.value - _rentPrice;
        payable (persons[_upc].nsfasID).transfer(amountToReturn);
    }

    // Define a modifier that checks if the paid amount is sufficient to cover the price
    modifier paidEnoughFees(uint256 _feesPrice) {
        require(msg.value >= _feesPrice);
        _;
    }

    // Define a modifier that checks the rent price and refunds the remaining balance
    modifier checkFeesValue(uint256 _upc) {
        _;
        uint256 _feesPrice = persons[_upc].feesPrice;
        uint256 amountToReturn = msg.value - _feesPrice;
        payable (persons[_upc].nsfasID).transfer(amountToReturn);
    }

    // Define a modifier that checks if a person.state of a upc has applied
    modifier applied_uni(uint256 _upc) {
        require(persons[_upc].personState == State.Applied_Uni, "Person has not applied");
        _;
    }

    // Define a modifier that checks if a person.state of a upc has been admitted
    modifier admitted(uint256 _upc) {
        require(persons[_upc].personState == State.Admitted, "Person has not been admitted");
        _;
    }

    // Define a modifier that checks if a person.state of a upc has registered
    modifier registered(uint256 _upc) {
        require(persons[_upc].personState == State.Registered, "Person has not registered");
        _;
    }

    // Define a modifier that checks if a person.state of a upc has applied
    modifier applied_accommodation(uint256 _upc) {
        require(persons[_upc].personState == State.Applied_Accommodation, "Person has not applied for accommodation");
        _;
    }

    // Define a modifier that checks if a person.state of a upc has applied
    modifier accepted(uint256 _upc) {
        require(persons[_upc].personState == State.Accepted, "Person has not been accepted for accommodation");
        _;
    }

    // Define a modifier that checks if a person.state of a upc has applied
    modifier applied_nsfas(uint256 _upc) {
        require(persons[_upc].personState == State.Applied_Nsfas, "Person has not applied for nsfas funding");
        _;
    }

    // Define a modifier that checks if a person.state of a upc has applied
    modifier approved(uint256 _upc) {
        require(persons[_upc].personState == State.Approved, "Person has not been approved for funding");
        _;
    }

    // Define a modifier that checks if a person.state of a upc has applied
    modifier requested_bookfunds(uint256 _upc) {
        require(persons[_upc].personState == State.Requested_BookFunds, "Book Funds not requested");
        _;
    }

    // Define a modifier that checks if a person.state of a upc has applied
    modifier paid_books(uint256 _upc) {
        require(persons[_upc].personState == State.Paid_Books, "Person has not been paid book funds");
        _;
    }

    // Define a modifier that checks if a person.state of a upc has applied
    modifier requested_monthlyfunds(uint256 _upc) {
        require(persons[_upc].personState == State.Requested_MonthlyFunds, "Monthly Funds not requested");
        _;
    }

    // Define a modifier that checks if a person.state of a upc has applied
    modifier paid_monthly(uint256 _upc) {
        require(persons[_upc].personState == State.Paid_Monthly, "Person has not been paid monthly funds");
        _;
    }

    // Define a modifier that checks if a person.state of a upc has applied
    modifier requested_rentfunds(uint256 _upc) {
        require(persons[_upc].personState == State.Requested_Rent, "Rent Funds not requested");
        _;
    }

    // Define a modifier that checks if a person.state of a upc has applied
    modifier paid_rent(uint256 _upc) {
        require(persons[_upc].personState == State.Paid_Rent, "Person has not paid rent");
        _;
    }

    // Define a modifier that checks if a person.state of a upc has applied
    modifier requested_unifunds(uint256 _upc) {
        require(persons[_upc].personState == State.Requested_UniFees, "Book Funds not requested");
        _;
    }

    // Define a modifier that checks if a person.state of a upc has applied
    modifier paid_fees(uint256 _upc) {
        require(persons[_upc].personState == State.Paid_Fees, "Person has not settled uni fees");
        _;
    }

    // // Define a modifier that checks if a person.state of a upc has applied
    // modifier eligible(uint256 _upc) {
    //     require(persons[_upc].personState == State.Eligible, "Person is not eligible for further funding by nsfas");
    //     _;
    // }

    // // Define a modifier that checks if a person.state of a upc has applied
    // modifier graduated(uint256 _upc) {
    //     require(persons[_upc].personState == State.Graduated, "Person has not applied");
    //     _;
    // }

    // In the constructor set 'owner' to the address that instantiated the contract
    // and set 'sku' to 1
    // and set 'upc' to 1
    constructor() payable {
        // owner = (msg.sender);
        sku = 1;
        upc = 1;
    }

    // Define a function 'applyUni' that mark a student as 'Applied_Uni'
    function applyUni(
        uint256 _upc,
        address _originStudentID,
        string memory _studentName,
        string memory _studentSurname,
        // string memory _personID,
        string memory _courseName,
        string memory _uniName,
        address _uniID
        //string memory _productNotes
    ) public onlyStudent {
        // Add the new person as part of applied
        persons[_upc].upc = _upc;
        persons[_upc].sku = sku;
        // persons[_upc].ownerID = msg.sender;
        persons[_upc].ownerID = _originStudentID;
        persons[_upc].originStudentID = _originStudentID;
        persons[_upc].studentName = _studentName;
        persons[_upc].studentSurname = _studentSurname;
        persons[_upc].personID = _upc + sku; // Product ID is a combo of upc + sku
        persons[_upc].courseName = _courseName;
        persons[_upc].uniName = _uniName;
        persons[_upc].uniID = _uniID;
        persons[_upc].personState = State.Applied_Uni;

        // Increment sku
        sku = sku + 1;
        // Emit the appropriate event
        emit Applied_Uni(_upc);
    }

    function admit(uint256 _upc)
        public
        // call modifier to check if upc has passed previous process
        applied_uni(_upc)
        // call modifier to verify caller of this function
        verifyCaller(persons[_upc].uniID)
        // onlyUniversity
        {
            persons[_upc].ownerID = msg.sender;
            persons[_upc].uniID = msg.sender;
            persons[_upc].personState = State.Admitted;
            emit Admitted(_upc);
        }

    function register(uint256 _upc)
        public
        // call modifier to check if upc has passed previous process
        admitted(_upc)
        // call modifier to verify caller of this function
        verifyCaller(persons[_upc].originStudentID)
        // onlyStudent
        {
            persons[_upc].ownerID = msg.sender;
            persons[_upc].originStudentID = msg.sender;
            persons[_upc].personState = State.Registered;
            emit Registered(_upc);
        }

    function apply_accommodation(uint256 _upc)
        public
        // call modifier to check if upc has passed previous process
        registered(_upc)
        // call modifier to verify caller of this function
        verifyCaller(persons[_upc].originStudentID)
        onlyStudent
        {
            persons[_upc].ownerID = msg.sender;
            persons[_upc].originStudentID = msg.sender;
            persons[_upc].personState = State.Applied_Accommodation;
            emit Applied_Accommodation(_upc);
        }

    function accepted_accommodation(uint256 _upc)
        public
        // call modifier to check if upc has passed previous process
        applied_accommodation(_upc)
        // call modifier to verify caller of this function
        verifyCaller(persons[_upc].accommodationID)
        // onlyAccommodation
        {
            persons[_upc].ownerID = msg.sender;
            persons[_upc].accommodationID = msg.sender;
            persons[_upc].personState = State.Accepted;
            emit Accepted(_upc);
        }

     function apply_nsfas(uint256 _upc)
        public
        // call modifier to check if upc has passed previous process
        accepted(_upc)
        // call modifier to verify caller of this function
        verifyCaller(persons[_upc].originStudentID)
        onlyStudent
        {
            persons[_upc].ownerID = msg.sender;
            persons[_upc].originStudentID = msg.sender;
            persons[_upc].personState = State.Applied_Nsfas;
            emit Applied_Nsfas(_upc);
        }

    function approved_nsfas(uint256 _upc)
        public
        // call modifier to check if upc has passed previous process
        applied_nsfas(_upc)
        // call modifier to verify caller of this function
        verifyCaller(persons[_upc].nsfasID)
        {
            persons[_upc].ownerID = msg.sender;
            persons[_upc].nsfasID = msg.sender;
            persons[_upc].personState = State.Approved;
            emit Approved(_upc);
        }

    function reqBookFund(uint256 _upc, uint256 _bookPrice)
        public
        // Call modifier to check if upc has passed previous process
        approved(_upc)
        // Call modifier to verify caller of this function
        verifyCaller(persons[_upc].originStudentID)
        {
            // Update the appropriate fields
            persons[_upc].personState = State.Requested_BookFunds;
            persons[_upc].bookPrice = _bookPrice;
            // Emit the appropriate event
            emit Requested_BookFunds(_upc);
        }

    function payBooks(uint256 _upc)
        public
        payable
        // Call modifier to check if upc has passed previous process
        requested_bookfunds(_upc)

        // Call modifier to check if NSFAS has paid enough
        paidEnoughBook(persons[_upc].bookPrice)

        // Call modifier to send any excess ether back to Nsfas
        checkBookValue(_upc)
        {
            // Update the appropriate fields - ownerID, nsfasID, personState
            persons[_upc].ownerID = msg.sender;
            persons[_upc].nsfasID = msg.sender;
            persons[_upc].personState = State.Paid_Books;

            // Transfer money to student
            payable(persons[_upc].nsfasID).transfer(persons[_upc].bookPrice);

            // emit the appropriate event
            emit Paid_Books(_upc);
        }

    function reqMonthlyFund(uint256 _upc, uint256 _monthlyPrice)
        public
        // Call modifier to check if upc has passed previous process
        paid_books(_upc)
        // Call modifier to verify caller of this function
        verifyCaller(persons[_upc].originStudentID)
        {
            // Update the appropriate fields
            persons[_upc].personState = State.Requested_MonthlyFunds;
            persons[_upc].monthlyPrice = _monthlyPrice;
            // Emit the appropriate event
            emit Requested_MonthlyFunds(_upc);
        }

    function payMonthly(uint256 _upc)
        public
        payable
        // Call modifier to check if upc has passed previous process
        requested_monthlyfunds(_upc)

        // Call modifier to check if NSFAS has paid enough
        paidEnoughMonthly(persons[_upc].monthlyPrice)

        // Call modifier to send any excess ether back to Nsfas
        checkMonthlyValue(_upc)
        {
            // Update the appropriate fields - ownerID, nsfasID, personState
            persons[_upc].ownerID = msg.sender;
            persons[_upc].nsfasID = msg.sender;
            persons[_upc].personState = State.Paid_Monthly;

            // Transfer money to student
            payable(persons[_upc].nsfasID).transfer(persons[_upc].monthlyPrice);

            // emit the appropriate event
            emit Paid_Monthly(_upc);
        }

    function reqRentFund(uint256 _upc, uint256 _rentPrice)
        public
        // Call modifier to check if upc has passed previous process
        paid_monthly(_upc)
        // Call modifier to verify caller of this function
        verifyCaller(persons[_upc].accommodationID)
        {
            // Update the appropriate fields
            persons[_upc].personState = State.Requested_Rent;
            persons[_upc].rentPrice = _rentPrice;
            // Emit the appropriate event
            emit Requested_Rent(_upc);
        }

    function payRent(uint256 _upc)
        public
        payable
        // Call modifier to check if upc has passed previous process
        requested_monthlyfunds(_upc)

        // Call modifier to check if NSFAS has paid enough
        paidEnoughRent(persons[_upc].rentPrice)

        // Call modifier to send any excess ether back to Nsfas
        checkRentValue(_upc)
        {
            // Update the appropriate fields - ownerID, nsfasID, personState
            persons[_upc].ownerID = msg.sender;
            persons[_upc].nsfasID = msg.sender;
            persons[_upc].personState = State.Paid_Rent;

            // Transfer money to student
            payable(persons[_upc].nsfasID).transfer(persons[_upc].monthlyPrice);

            // emit the appropriate event
            emit Paid_Rent(_upc);
        }

    function reqFeesFund(uint256 _upc, uint256 _feesPrice)
        public
        // Call modifier to check if upc has passed previous process
        paid_rent(_upc)
        // Call modifier to verify caller of this function
        verifyCaller(persons[_upc].uniID)
        {
            // Update the appropriate fields
            persons[_upc].personState = State.Requested_UniFees;
            persons[_upc].feesPrice = _feesPrice;
            // Emit the appropriate event
            emit Requested_UniFees(_upc);
        }

    function payFees(uint256 _upc)
        public
        payable
        // Call modifier to check if upc has passed previous process
        requested_unifunds(_upc)
        // Call modifier to verify if NSFAS has paid enough
        paidEnoughFees(persons[_upc].feesPrice)

        // Call modifier to send any excess ether back to Nsfas
        checkFeesValue(_upc)
        {
            // Update the appropriate fields - ownerID, nsfasID, personState
            persons[_upc].ownerID = msg.sender;
            persons[_upc].nsfasID = msg.sender;
            persons[_upc].personState = State.Paid_Fees;

            // Transfer money to university
            payable(persons[_upc].nsfasID).transfer(persons[_upc].feesPrice);

            // emit the appropriate event
            emit Paid_Fees(_upc);
        }

    // Define a function 'fetchItemBufferOne' that fetches the data
    function fetchPersonBufferOne(uint256 _upc)
        public
        view
        returns (
            uint256 personSKU,
            uint256 personUPC,
            address ownerID,
            address originStudentID,
            string memory studentName,
            string memory studentSurname

        )
    {
        // Assign values to the 8 parameters
        personSKU = persons[_upc].sku;
        personUPC = persons[_upc].upc;
        ownerID = persons[_upc].ownerID;
        originStudentID = persons[_upc].originStudentID;
        studentName = persons[_upc].studentName;
        studentSurname = persons[_upc].studentSurname;

        return (
            personSKU,
            personUPC,
            ownerID,
            originStudentID,
            studentName,
            studentSurname
        );
    }

    // Define a function 'fetchPersonBufferTwo' that fetches the data
    function fetchPersonBufferTwo(uint256 _upc)
        public
        view
        returns (
            // uint256 personSKU,
            // uint256 personUPC,
            uint256 personID,
            // string memory studentName,
            // string memory studentSurname, // Student Surname
            string memory uniName,
            string memory courseName, // Course Applying for by person
            uint256 bookPrice, // Book Price
            uint256 monthlyPrice, // Monthly Price
            uint256 rentPrice, // Accommodation Price
            uint256 feesPrice, // University Fees Price
            // uint256 passRate; // Pass rate of the student
            uint256 personState, // Person State as represented in the enum above
            // address studentID; // Metamask-Ethereum address of the student
            address uniID, // Metamask-Ethereum address of the University
            address accommodationID, // Metamask-Ethereum address of the Accommodation
            address nsfasID // Metamask-Ethereum address of Nsfas
            
        )
    {
        // Assign values to the 15 or 16 parameters
        // personSKU = persons[_upc].sku;
        // personUPC = persons[_upc].upc;
        personID = persons[_upc].personID;
        // studentName = persons[_upc].studentName;
        // studentSurname = persons[_upc].studentSurname;
        uniName = persons[_upc].uniName;
        courseName = persons[_upc].courseName;
        bookPrice = persons[_upc].bookPrice;
        monthlyPrice = persons[_upc].monthlyPrice;
        rentPrice = persons[_upc].rentPrice;
        feesPrice = persons[_upc].feesPrice;
        personState = uint256(persons[_upc].personState);
        uniID = persons[_upc].uniID;
        accommodationID = persons[_upc].accommodationID;
        nsfasID = persons[_upc].nsfasID;

        return (
            // personSKU,
            // personUPC,
            personID,
            // studentName,
            // studentSurname,
            uniName,
            courseName,
            bookPrice,
            monthlyPrice,
            rentPrice,
            feesPrice,
            personState,
            uniID,
            accommodationID,
            nsfasID
        );
    }
    
}