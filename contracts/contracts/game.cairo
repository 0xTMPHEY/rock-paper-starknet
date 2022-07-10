%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, assert_not_zero, assert_nn_le
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math_cmp import is_nn
from starkware.starknet.common.syscalls import get_caller_address

const ROCK = 0
const PAPER = 1
const SCISSORS = 2

@contract_interface
namespace ChancesContractInterface:
    func choose_on_chances(chances_len : felt, chances : felt*) -> (index : felt, rnd : felt):
    end
end

@storage_var
func chances_contract() -> (address : felt):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    chances_address : felt
):
    chances_contract.write(value=chances_address)
    return ()
end

@view
func play{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(move : felt) -> (
    player_move : felt, npc_move : felt, player_won : felt
):
    alloc_locals

    let (caller) = get_caller_address()

    with_attr error_message("Wrong move"):
        assert_nn_le(move, SCISSORS)
    end

    let (npc_move) = generate_npc_move()
    local player_won

    if move == npc_move:
        return (player_move=move, npc_move=npc_move, player_won=0)
    end

    if move == ROCK:
        if npc_move == PAPER:
            player_won = 0
        else:
            player_won = 1
        end
    end

    if move == PAPER:
        if npc_move == SCISSORS:
            player_won = 0
        else:
            player_won = 1
        end
    end

    if move == SCISSORS:
        if npc_move == ROCK:
            player_won = 0
        else:
            player_won = 1
        end
    end

    return (player_move=move, npc_move=npc_move, player_won=player_won)
end

@view
func generate_npc_move{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    alloc_locals
    let (local chances : felt*) = alloc()
    assert chances[0] = 30
    assert chances[1] = 30
    assert chances[2] = 30

    let (chances_address) = chances_contract.read()

    let (index, rnd) = ChancesContractInterface.choose_on_chances(
        contract_address=chances_address, chances_len=3, chances=chances
    )
    return (res=index)
end
