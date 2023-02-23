import json
from secrets import token_bytes
from coincurve import PublicKey
from sha3 import keccak_256

address_dict = {}
for i in range(1,501):
    private_key = keccak_256(token_bytes(32)).digest()
    public_key = PublicKey.from_valid_secret(private_key).format(compressed=False)[1:]
    addr = keccak_256(public_key).digest()[-20:]
    address_dict['0x'+addr.hex()] = i

# import our "presaleUser1"
address_dict["0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69"] = 501

for i in range(502, 1001):
    private_key = keccak_256(token_bytes(32)).digest()
    public_key = PublicKey.from_valid_secret(private_key).format(compressed=False)[1:]
    addr = keccak_256(public_key).digest()[-20:]
    address_dict['0x'+addr.hex()] = i

json_addresses = json.dumps(address_dict, indent=4)
with open("whitelist.json", "w") as outfile:
    outfile.write(json_addresses)
