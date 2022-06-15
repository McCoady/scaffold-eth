import { useBalance, useContractReader } from "eth-hooks";
import { useEventListener } from "eth-hooks/events/useEventListener";
import { ethers } from "ethers";
import { Button, Card, Input, List } from "antd";
import { Address, Balance } from "../components";
import React, { useState } from "react";
import { Link } from "react-router-dom";


/**
 * web3 props can be passed from '../App.jsx' into your local view component for use
 * @param {*} yourLocalBalance balance on current network
 * @param {*} readContracts contracts from current chain already pre-loaded using ethers contract module. More here https://docs.ethers.io/v5/api/contract/contract/
 * @returns react component
 **/
function Home({ tx, yourLocalBalance, writeContracts, readContracts, localProvider, mainnetProvider, price }) {



  const bountyBoosterAddress = readContracts && readContracts.BountyBooster && readContracts.BountyBooster.address;

  const boostNft = useContractReader(readContracts, "BountyBooster", "boostNft");
  const boosterBalance = useContractReader(readContracts, "BountyBooster", "boostBalance");

  const [donating, setDonating] = useState();
  const [donateAmount, setDonateAmount] = useState({
    valid: false,
    value: ''
  });

  const [creatingBounty, setCreatingBounty] = useState();
  const [bountyDescription, setBountyDescription] = useState();
  const [bountyAmount, setBountyAmount] = useState({
    valid: false,
    value: ''
  })
  const [bountyDeadline, setBountyDeadline] = useState();

  const [bountyId, setBountyId] = useState();
  const [withdrawBounty, setWithdrawBounty] = useState();

  const [bountyCompleter, setBountyCompleter] = useState();
  const [acceptBounty, setAcceptBounty] = useState();

  const bountyCreatedEvents = useEventListener(readContracts, "BountyBooster", "BountyCreated", localProvider, 1);
  console.log("📟 bountyCreatedEvents:", bountyCreatedEvents);
  const bountyCompletedEvents = useEventListener(readContracts, "BountyBooster", "BountyCompleted", localProvider, 1);
  console.log("📟 bountyCompletedEvents:", bountyCompletedEvents);

  return (
    <div>
      <div style={{ margin: 32 }}>
        <div style={{ width: 500, margin: "auto", marginTop: 64 }}>
          <div>Bounty Created Events:</div>
          <List
            dataSource={bountyCreatedEvents}
            renderItem={item => {
              return (
                <List.Item key={item.blockNumber + item.blockHash}>
                  <Address value={item.args[0]} ensProvider={mainnetProvider} fontSize={16} />
                  <br />created bounty #{item.args[3].toNumber()}: "{item.args[1]}." for
                  <Balance balance={item.args[2]} dollarMultiplier={price} />
                </List.Item>
              );
            }}
          />
        </div>
        <Card title="Bounty Contract Balance" extra={<a href="#"></a>}>
          <div style={{ padding: 8 }}>
            <Balance balance={boosterBalance} dollarMultiplier={price} fontSize={64} />
          </div>
          <Input
            style={{ textAlign: "center" }}
            placeholder={"amount of eth to donate to booster"}
            value={donateAmount.value}
            onChange={e => {
              const newValue = e.target.value.startsWith(".") ? "0." : e.target.value;
              const donAmount = {
                value: newValue,
                valid: /^\d*\.?\d+$/.test(newValue)
              }
              setDonateAmount(donAmount);
            }}
          />
          <div style={{ padding: 8 }}>
            <Button
              type={"primary"}
              loading={donating}
              onClick={async () => {
                setDonating(true);
                await tx(writeContracts.BountyBooster.addToBoostBalance({ value: ethers.utils.parseEther(donateAmount.value) }));
                setDonating(false);
              }}
            >
              Donate ETH
            </Button>
          </div>
        </Card>
        <Card title="Create New Bounty" extra={<a href="#"></a>}>
          <Input
            style={{ textAlign: "center" }}
            placeholder={"Bounty ETH Amount"}
            value={bountyAmount.value}
            onChange={e => {
              const newValue = e.target.value.startsWith(".") ? "0." : e.target.value;
              const bAmount = {
                value: newValue,
                valid: /^\d*\.?\d+$/.test(newValue)
              }
              setBountyAmount(bAmount);
            }}
          />
          <Input
            style={{ textAlign: "center" }}
            placeholder={"Bounty Description"}
            value={bountyDescription}
            onChange={e => {
              setBountyDescription(e.target.value);
            }}
          />
          <Input
            style={{ textAlign: "center" }}
            placeholder={"Bounty Deadline"}
            value={bountyDeadline}
            onChange={e => {
              setBountyDeadline(e.target.value);
            }}
          />
          <div style={{ padding: 8 }}>
            <Button
              type={"primary"}
              loading={creatingBounty}
              onClick={async () => {
                setCreatingBounty(true);
                await tx(writeContracts.BountyBooster.postBounty(bountyDescription, bountyDeadline, { value: ethers.utils.parseEther(bountyAmount.value) }));
                setCreatingBounty(false);
              }}
            >
              Create a bounty
            </Button>
          </div>
        </Card>
        <Card title="Created Accept Bounty" extra={<a href="#"></a>}>
          <Input
            style={{ textAlign: "center" }}
            placeholder={"Bounty ID"}
            value={bountyId}
            onChange={e => {
              setBountyId(e.target.value);
            }}
          />
          <Input
            style={{ textAlign: "center" }}
            placeholder={"Bounty Completer's address"}
            value={bountyCompleter}
            onChange={e => {
              setBountyCompleter(e.target.value);
            }}
          />
          <div style={{ padding: 8 }}>
            <Button
              type={"primary"}
              loading={acceptBounty}
              onClick={async () => {
                setAcceptBounty(true);
                await tx(writeContracts.BountyBooster.acceptBounty(bountyId, bountyCompleter));
                setAcceptBounty(false);
              }}
            >
              Withdraw Funds
            </Button>
          </div>
        </Card>
        <Card title="Withdraw Expired Bounty" extra={<a href="#"></a>}>
          <Input
            style={{ textAlign: "center" }}
            placeholder={"Bounty ID"}
            value={bountyId}
            onChange={e => {
              setBountyId(e.target.value);
            }}
          />
          <div style={{ padding: 8 }}>
            <Button
              type={"primary"}
              loading={withdrawBounty}
              onClick={async () => {
                setWithdrawBounty(true);
                await tx(writeContracts.BountyBooster.withdrawBountyFunds(bountyId));
                setWithdrawBounty(false);
              }}
            >
              Withdraw Funds
            </Button>
          </div>
        </Card>
      </div>
    </div>
  );
}

export default Home;
