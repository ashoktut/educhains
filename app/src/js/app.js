App = {
    web3Provider: null,
    contracts: {},
    emptyAddress: "0x0000000000000000000000000000000000000000",
    sku: 0,
    upc: 0,
    metamaskAccountID: "0x0000000000000000000000000000000000000000",
    ownerID: "0x0000000000000000000000000000000000000000",
    originStudentID: "0x0000000000000000000000000000000000000000",
    studentName: null,
    studentSurname: null,
    courseName: null,
    uniName: null,
    bookPrice: 0,
    monthlyPrice: 0,
    rentPrice: 0,
    feesPrice: 0,
    uniID: "0x0000000000000000000000000000000000000000",
    accommodationrID: "0x0000000000000000000000000000000000000000",
    nsfasID: "0x0000000000000000000000000000000000000000",
    

    init: async function () {
        App.readForm();
        /// Setup access to blockchain
        return await App.initWeb3();
    },

    readForm: function () {
        App.sku = $("#sku").val();
        App.upc = $("#upc").val();
        App.ownerID = $("#ownerID").val();
        App.originStudentID = $("#originStudentID").val();
        App.studentName = $("#studentName").val();
        App.studentSurname = $("#studentSurname").val();
        App.courseName = $("#courseName").val();
        App.uniName = $("#uniName").val();
        App.bookPrice = $("#bookPrice").val();
        App.monthlyPrice = $("#monthlyPrice").val();
        App.rentPrice = $("#rentPrice").val();
        App.feesPrice = $("#feesPrice").val();
        App.uniID = $("#uniID").val();
        App.accommodationID = $("#accommodationID").val();
        App.nsfasID = $("#nsfasID").val();

        console.log(
            App.sku,
            App.upc,
            App.ownerID,
            App.originStudentID,
            App.studentName,
            App.studentSurname,
            App.courseName,
            App.uniName,
            App.bookPrice,
            App.monthlyPrice,
            App.rentPrice,
            App.feesPrice,
            App.uniID,
            App.accommodationID,
            App.nsfasID
        );
    },

    initWeb3: async function () {
        /// Find or Inject Web3 Provider
        /// Modern dapp browsers...
        if (window.ethereum) {
            App.web3Provider = window.ethereum;
            try {
                // Request account access
                await window.ethereum.enable();
            } catch (error) {
                // User denied account access...
                console.error("User denied account access")
            }
        }
        // Legacy dapp browsers...
        else if (window.web3) {
            App.web3Provider = window.web3.currentProvider;
        }
        // If no injected web3 instance is detected, fall back to Ganache
        else {
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
        }

        App.getMetaskAccountID();

        return App.initEduChain();
    },

    getMetaskAccountID: function () {
        web3 = new Web3(App.web3Provider);

        // Retrieving accounts
        web3.eth.getAccounts(function(err, res) {
            if (err) {
                console.log('Error:',err);
                return;
            }
            console.log('getMetaskID:',res);
            App.metamaskAccountID = res[0];

        })
    },

    initEduChain: function () {
        /// Source the truffle compiled smart contracts
        var jsonEduChain='../../build/contracts/EduChain.json';
        
        /// JSONfy the smart contracts
        $.getJSON(jsonEduChain, function(data) {
            console.log('data',data);
            var EduChainArtifact = data;
            App.contracts.EduChain = TruffleContract(EduChainArtifact);
            App.contracts.EduChain.setProvider(App.web3Provider);
            
            App.fetchPersonBufferOne();
            App.fetchPesonBufferTwo();
            App.fetchEvents();

        });

        return App.bindEvents();
    },

    bindEvents: function() {
        $(document).on('click', App.handleButtonClick);
    },

    handleButtonClick: async function(event) {
        event.preventDefault();

        App.getMetaskAccountID();

        var processId = parseInt($(event.target).data('id'));
        console.log('processId',processId);

        switch(processId) {
            case 1:
                return await App.applyUni(event);
                break;
            case 2:
                return await App.admit(event);
                break;
            case 3:
                return await App.register(event);
                break;
            case 4:
                return await App.apply_accommodation(event);
                break;
            case 5:
                return await App.accepted_accommodation(event);
                break;
            case 6:
                return await App.apply_nsfas(event);
                break;
            case 7:
                return await App.approved_nsfas(event);
                break;
            case 8:
                return await App.reqBookFund(event);
                break;
            case 9:
                return await App.payBooks(event);
                break;
            case 10:
                    return await App.reqMonthlyFund(event);
                    break;  
            case 11:
                return await App.payMonthly(event);
                break;
            case 12:
                return await App.reqRentFund(event);
                break;   
            case 13:
                return await App.payRent(event);
                break; 
            case 14:
                return await App.reqFeesFund(event);
                break;  
            case 15:
                return await App.payFees(event);
                break;              
            case 16:
                return await App.fetchPersonBufferOne(event);
                break;
            case 17:
                return await App.fetchPersonBufferTwo(event);
                break;
            }
    },

    applyUni: function(event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.EduChain.deployed().then(function(instance) {
            return instance.applyUni(
                App.upc, 
                App.metamaskAccountID, 
                App.studentName, 
                App.studentSurname, 
                App.courseName, 
                App.uniName, 
                {from : App.metamaskAccountID}
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('applyUni',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    admit: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.EduChain.deployed().then(function(instance) {
            return instance.admit(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('admit',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },
    
    register: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.EduChain.deployed().then(function(instance) {
            return instance.register(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('register',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    apply_accommodation: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.EduChain.deployed().then(function(instance) {
            return instance.apply_accommodation(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('apply_accommodation',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    accepted_accommodation: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.EduChain.deployed().then(function(instance) {
            return instance.accepted_accommodation(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('accepted_accommodation',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },
    
    apply_nsfas: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.EduChain.deployed().then(function(instance) {
            return instance.apply_nsfas(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('apply_nsfas',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    approved_nsfas: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.EduChain.deployed().then(function(instance) {
            return instance.approved_nsfas(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('approved_nsfas',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },


    reqBookFund: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.EduChain.deployed().then(function(instance) {
            const bookPrice = web3.toWei("0.01", "ether");
            console.log('bookPrice',bookPrice);
            return instance.reqBookFund(App.upc, App.bookPrice, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('reqBookFund',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    payBooks: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.EduChain.deployed().then(function(instance) {
            const walletValue = web3.toWei("0.01", "ether");
            return instance.payBooks(App.upc, {from: App.metamaskAccountID, value: walletValue});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('payBooks',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    reqMonthlyFund: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.EduChain.deployed().then(function(instance) {
            const monthlyPrice = web3.toWei("0.01", "ether");
            console.log('monthlyPrice',monthlyPrice);
            return instance.reqMonthlyFund(App.upc, App.monthlyPrice, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('reqMonthlyFund',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },   

    payMonthly: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.EduChain.deployed().then(function(instance) {
            const walletValue = web3.toWei("0.01", "ether");
            return instance.payMonthly(App.upc, {from: App.metamaskAccountID, value: walletValue});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('payMonthly',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    reqRentFund: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.EduChain.deployed().then(function(instance) {
            const rentPrice = web3.toWei("0.01", "ether");
            console.log('rentPrice',rentPrice);
            return instance.reqRentFund(App.upc, App.rentPrice, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('reqRentFund',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },
    
    payRent: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.EduChain.deployed().then(function(instance) {
            const walletValue = web3.toWei("0.01", "ether");
            return instance.payRent(App.upc, {from: App.metamaskAccountID, value: walletValue});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('payRent',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    reqFeesFund: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.EduChain.deployed().then(function(instance) {
            const feesPrice = web3.toWei("0.01", "ether");
            console.log('feesPrice',feesPrice);
            return instance.reqFeesFund(App.upc, App.feesPrice, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('reqFeesFund',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },
    
    payFees: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.EduChain.deployed().then(function(instance) {
            const walletValue = web3.toWei("0.01", "ether");
            return instance.payFees(App.upc, {from: App.metamaskAccountID, value: walletValue});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('payFees',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    fetchPersonBufferOne: function () {
    ///   event.preventDefault();
    ///    var processId = parseInt($(event.target).data('id'));
        App.upc = $('#upc').val();
        console.log('upc',App.upc);

        App.contracts.EduChain.deployed().then(function(instance) {
          return instance.fetchPersonBufferOne(App.upc);
        }).then(function(result) {
          $("#ftc-item").text(result);
          console.log('fetchPersonBufferOne', result);
        }).catch(function(err) {
          console.log(err.message);
        });
    },

    fetchPersonBufferTwo: function () {
    ///    event.preventDefault();
    ///    var processId = parseInt($(event.target).data('id'));
                        
        App.contracts.EduChain.deployed().then(function(instance) {
          return instance.fetchPersonBufferTwo.call(App.upc);
        }).then(function(result) {
          $("#ftc-item").text(result);
          console.log('fetchPersonBufferTwo', result);
        }).catch(function(err) {
          console.log(err.message);
        });
    },

    fetchEvents: function () {
        if (typeof App.contracts.EduChain.currentProvider.sendAsync !== "function") {
            App.contracts.EduChain.currentProvider.sendAsync = function () {
                return App.contracts.EduChain.currentProvider.send.apply(
                App.contracts.EduChain.currentProvider,
                    arguments
              );
            };
        }

        App.contracts.EduChain.deployed().then(function(instance) {
        var events = instance.allEvents(function(err, log){
          if (!err)
            $("#ftc-events").append('<li>' + log.event + ' - ' + log.transactionHash + '</li>');
        });
        }).catch(function(err) {
          console.log(err.message);
        });
        
    }
};

$(function () {
    $(window).load(function () {
        App.init();
    });
});
