# ERC-3643 = ERC-20 + Identity + Compliance Layer

Use cases: Stock tokenization, RWA, Real estate tokenization, fund shares.

ERC-3643 là tiêu chuẩn token dành cho tài sản được quản lý, kết hợp ERC-20 với identity và compliance để đáp ứng yêu cầu pháp lý trong việc token hoá tài sản thực.

### 1. Token core
Have full abilities as ERC-20

Override logic transfer

```
require(
  compliance.canTransfer(from, to, amount),
  "Transfer not allowed"
);
```

### 2. Identity (ERC-734 / ERC-735)

Each user not only a address but also identity contract

Store these information
+ KYC passed, country
+ Claim be signed by trusted issuer


### 3. Compliance modules

Has rules that it can switch off/on

+ Max investor
+ Country restriction
+ Lock-up period
+ Transfer only between verified identities
+ Time-based restriction


