<template>
  <div id="app">
    <header>
      Account: {{ account }}
      <br>
      Balance: {{ web3.utils.fromWei(balance, 'ether') }}
    </header>
    <section>
      <h2>Deposit</h2>
      How much do you want to deposit?
      <br><br>
      (min. amount is 0.01 ETH)
      <br><br>

      <input
        v-model="depositAmount"
        step="0.01"
        type='number'>

      <button @click="deposit">DEPOSIT</button>

    </section>
    <hr>
    <section>
      <h2>Withdraw</h2>

      Do you want to withdraw + take interest
      <br><br>

      <button @click="withdraw">WITHDRAW</button>
    </section>
  </div>
</template>

<script>
  import dBank from './contracts/dBank.json'
  import Token from './contracts/Token.json'
  import Web3 from 'web3'


  export default {
    name: 'app',
    data () {
      return {
        web3: undefined,
        account: '',
        token: null,
        dbank: null,
        balance: 0,
        dBankAddress: null,
        depositAmount: 0,
      }

    },
    async mounted () {
      await this.loadBlockchainData()
    },
    methods: {
      async loadBlockchainData () {
        if (typeof window.ethereum !== 'undefined') {
          this.web3 = new Web3(window.ethereum)
          const netId = await this.web3.eth.net.getId()
          const accounts = await this.web3.eth.getAccounts()
          this.account = accounts[0]
          //load balance
          if (typeof accounts[0] !== 'undefined') {
            this.balance = await this.web3.eth.getBalance(accounts[0])
          } else {
            window.alert('Please login with MetaMask')
          }

          //load contracts
          try {
            this.token = new this.web3.eth.Contract(Token.abi, Token.networks[netId].address)
            this.dbank = new this.web3.eth.Contract(dBank.abi, dBank.networks[netId].address)
            this.dBankAddress = dBank.networks[netId].address
          } catch (e) {
            /* eslint-disable no-console*/

            console.log('Error', e)
            window.alert('Contracts not deployed to the current network')
          }
        } else {
          window.alert('Please install MetaMask')
        }
      },

      async deposit () {
        if (this.dbank !== 'undefined') {
          const amount = this.web3.utils.toWei(this.depositAmount, 'ether')
          try {
            await this.dbank.methods.deposit().send({ value: amount, from: this.account })
          } catch (e) {
            console.log('Error, deposit: ', e)
          }
        }
      },

      async withdraw () {
        if (this.dbank !== 'undefined') {
          try {
            await this.dbank.methods.withdraw().send({ from: this.account })
          } catch (e) {
            console.log('Error, withdraw: ', e)
          }
        }
      },

    },
  }
</script>

<style>
  #app {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
  }
</style>
