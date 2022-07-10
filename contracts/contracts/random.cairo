# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.math import unsigned_div_rem, assert_not_zero
from starkware.cairo.common.bitwise import bitwise_and
from starkware.starknet.common.syscalls import get_caller_address

@contract_interface
namespace IRandomContract:
    func get_random() -> (res : felt):
    end
end

@storage_var
func owner() -> (owner_address : felt):
end

@storage_var
func vrf_contract() -> (address : felt):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner_address : felt
):
    owner.write(value=owner_address)
    return ()
end

@external
func update_owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    new_owner : felt
):
    let (caller_address) = get_caller_address()
    let (owner_address) = owner.read()

    with_attr error_message("invalid owner"):
        assert caller_address = owner_address
    end

    assert_not_zero(new_owner)

    owner.write(value=new_owner)

    return ()
end

@external
func set_vrf_contract_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
):
    let (caller_address) = get_caller_address()
    let (owner_address) = owner.read()

    with_attr error_message("invalid owner"):
        assert caller_address = owner_address
    end

    with_attr error_message("contract cant be zero"):
        assert_not_zero(address)
    end

    vrf_contract.write(value=address)

    return ()
end

@view
func get_owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    owner_address : felt
):
    let (owner_address) = owner.read()
    return (owner_address)
end

@view
func get_random{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}(mod : felt) -> (res : felt):
    let (vrf_address) = vrf_contract.read()
    let (big_random) = IRandomContract.get_random{range_check_ptr=range_check_ptr}(
        contract_address=vrf_address
    )
    let (rnd) = bitwise_and(big_random, 2 ** 128 - 1)
    let (_, res) = unsigned_div_rem(rnd, mod)
    return (res)
end
