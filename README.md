# steakmaster
Stake Master Project 

This project has been created to provide a decentralized way of staking value for business purposes. It enable service providers to put up slashable stakes, inexchange for business concessions that carry significant risk for the client. 
An example of this would be immediate payment to a provider for a service to be delivered over a period of time. In exchange the provider would put up a value stake of significant size such that if the value were to be slashed it would result in a loss greater than the value associated with the delivery of the service.   

The staking mechanism uses smart contracts therefore can be linked into the business transaction process. 
Each stake has an owner responsible for paying the value of the stake and a holder responsible for releasing the stake or slashing the stake dependant on the "out of band" business delivery. 
The positive case objective is for the stake to be released back to the stake owner by the holder. 
The negative case is that the stake is slashed by the holder. 

Slashing 
The slashing behaviour of the Stake Master is based on the slash rules presented by the Stake Owner. The Stake Holder has to provide onchain proof of violation of the slash rules
for a slash request to be successful. This proof is verified by the Stake Master during execution of the slash rules. Slash Requests incur a fee on the Stake Holder. 
The Stake Owner can contest a slash request, this incurs a fee. At this point the slash is moved into a holding area and held there until the either the Time To Live expires where
upon the slash resumes or the slash is settled for a fee by both parties. Settlement consists of an agreement that is signed by both parties on chain but agreed "out of band."

