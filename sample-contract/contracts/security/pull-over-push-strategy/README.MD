## Pull over push 
[REF](https://fravoll.github.io/solidity-patterns/pull_over_push.html#:~:text=In%20order%20to%20isolate%20all,sent%20to%20him%20(push).)

```text
In order to isolate all external calls from each other and the contract logic, 
the Pull over Push pattern shifts the risk associated with the ether transfer to the user, 
by letting him withdraw (pull) a certain amount, which would otherwise have to be sent to him (push).
```