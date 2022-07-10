%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.math import unsigned_div_rem, assert_not_zero
from starkware.cairo.common.math_cmp import is_nn
from starkware.cairo.common.bitwise import bitwise_and
from starkware.starknet.common.syscalls import get_caller_address

const RNG_ADDRESS = 0x016bd0514cd777213633fa0e2c6d607ceef389b9e29727b20072fdeb0b140722

@contract_interface
namespace IRandomContract:
    func get_random(mod : felt) -> (res : felt):
    end
end

@view
func choose_on_chances{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}(chances_len : felt, chances : felt*) -> (index : felt, random : felt):
    alloc_locals

    with_attr error_message("Invalid length"):
        assert_not_zero(chances_len)
    end

    let (local sum) = array_sum(a_len=chances_len, a=chances)
    let (local rnd) = IRandomContract.get_random(contract_address=RNG_ADDRESS, mod=sum)
    let (local win_index) = choose(chances_len, chances, 0, rnd)

    return (index=win_index, random=rnd)
end

func choose{range_check_ptr}(probs_len : felt, probs : felt*, index : felt, random : felt) -> (
    res : felt
):
    if probs_len == 1:
        return (res=index)
    end
    let (nn) = is_nn(random - probs[0])
    if nn == 0:
        return (res=index)
    end

    let (res) = choose(
        probs_len=probs_len - 1, probs=probs + 1, index=index + 1, random=random - probs[0]
    )
    return (res)
end

func array_sum(a_len : felt, a : felt*) -> (sum : felt):
    if a_len == 0:
        return (sum=0)
    end
    let (sum_of_rest) = array_sum(a_len=a_len - 1, a=a + 1)
    return (sum=[a] + sum_of_rest)
end
