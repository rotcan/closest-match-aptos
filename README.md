# closest-match-aptos
A fully on-chain card game for 2 to 4 players
It uses randomness provided in Aptos chain along with zk proofs to store player moves.

Rules
A player can start game by having a fixed bet size(can be 0), number of rounds(3-6) and max time between moves. After game is setup, they wait for others to join. After all players have joined the game, cards are randomly distributed to each player and a card is randomly drawn from deck. In each move there are two steps. First is that each player has to play a card which they think will win them the round. Round is won by the card which is closest to the card on the table. When all players have player their cards (hidden from each other). They reveal their cards and winner gets 3 points. If there are more than 1 winner then each winner gets 1 point. At the end whoever has the highest points wins the game


How randomness is used
It is used to distribute card in random manner to players along with generating deck card randomly per round

How zk proofs are used
This game requires that each player plays their card without others knowing what the card is. After all players have played their card then they can reveal their cards. To acheive this zk circuit is used to hide the identity of the card from other players but at the same time ensuring player cannot cheat and reveal a different card. Groth16 is used to prove zk proof on chain as they are easy to implement and use less computation

Improvements
Slight improvment in gameplay will be to not have one round after another but show all deck cards in one go. Then player has to plan and guess what other players will play before revealing their cards
Fix UI to be more player friendly and use indexer for faster data retreival
Reduce gas costs and check security and edge cases
Store on chain objects offline and store verifiable hash on chain to reduce gas cost . But this requires off chain indexing of objects
Store user salts used in zk circuits in backend so that they are not lost if person clears their storage
