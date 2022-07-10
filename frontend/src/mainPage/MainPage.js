import { useEffect } from "react"
import { useState } from "react"
import * as styles from "./MainPage.module.css"
import { useContract, useStarknet } from "@starknet-react/core"
import { bigNumberishArrayToDecimalStringArray } from "starknet/dist/utils/number"
import * as gameAbi from '../../abi/game.json'

const shortAddress = (longAddress) => {
    const first = longAddress.slice(0, 6)
    const last = longAddress.slice(-4)
    return `${first}...${last}`
}

const useGameContract = () => {
    return useContract({
        abi: gameAbi,
        address: '0x01c30fdf0a30fb529c39193d205dca1eb0af20889fed11f174ea462f0a31890a'
    })
}

export function ConnectWallet() {
    const { account, connect, disconnect, connectors } = useStarknet()
    
    if (account) {
        return (
            <div className={styles.connectBtn} onClick={() => disconnect()}>
                {shortAddress(account)}
            </div>
        )
    }

    return (
        <>
            {connectors.map((connector, idx) => (
                <button className={styles.connectBtn} key={idx} onClick={() => connect(connector)}>
                    Connect
                </button>
            ))}
        </>
    )
}

export function MainPage() {
    const { account } = useStarknet()
    const { contract } = useGameContract()

    let [started, setStarted] = useState(false)
    let [userMakeMove, setUserMakeMove] = useState(false)
    let [endOfgame, setEndOfGame] = useState(false)
    let [winnerAnnouncment, setWinnerAnnouncment] = useState(null)
    let [rockClass, setRockClass] = useState(styles.rock)
    let [paperClass, setPaperClass] = useState(styles.paper)
    let [scissorsClass, setScissorsClass] = useState(styles.scissors)
    let [backsideClass1, setbacksideClass1] = useState(styles.backside1)
    let [backsideClass2, setbacksideClass2] = useState(styles.backside2)
    let [backsideClass3, setbacksideClass3] = useState(styles.backside3)

    const play = async (move) => {
        console.log('Playing with move', move)

        if (!userMakeMove) {

            setTimeout(() => setbacksideClass1(styles.opponentMove), 500)

            if (move == 0) {
                setRockClass(styles.userMove)
                setTimeout(() => setRockClass(styles.userMoveRock), 1500)
            } else if (move == 1) {
                setPaperClass(styles.userMove)
                setTimeout(() => setPaperClass(styles.userMovePaper), 1500)
            } else if (move == 2) {
                setScissorsClass(styles.userMove)
                setTimeout(() => setScissorsClass(styles.userMoveScissors), 1500)
            }

            const invokeResult = await contract.play(move)
            const [playerMove, npcMove, playerWon] = bigNumberishArrayToDecimalStringArray(invokeResult)
            .map(n => parseInt(n))

            console.log(playerMove, npcMove, playerWon)

            setTimeout(() => {
                if (npcMove == 0) {
                    setbacksideClass1(styles.opponentMoveRock)
                } else if (npcMove == 1) {
                    setbacksideClass1(styles.opponentMovePaper)
                } else if (npcMove == 2) {
                    setbacksideClass1(styles.opponentMoveScissors)
                }

                if (move == 0) {
                    setRockClass(styles.userMoveRock)
                } else if (move == 1) {
                    setPaperClass(styles.userMovePaper)
                } else if (move == 2) {
                    setScissorsClass(styles.userMoveScissors)
                }
            }, 200)

            if (playerMove == npcMove) {
                setWinnerAnnouncment("Draw😑")
            } else if (playerWon) {
                setWinnerAnnouncment("You win!🥳")
            } else {
                setWinnerAnnouncment("You lose☹️")
            }

            setTimeout(() => {
                setEndOfGame(true)
            }, 2000)
        }
    }

    function restart() {
        setEndOfGame(false)
        setWinnerAnnouncment(null)
        setUserMakeMove(false)
        setRockClass(styles.rock)
        setPaperClass(styles.paper)
        setScissorsClass(styles.scissors)
        setbacksideClass1(styles.backside1)
    }

    return (
        <div className={styles.mainConteiner}>
            <ConnectWallet/>
            {/* <button className={styles.connectBtn}>Connect wallet</button> */}
            <div className={styles.logoConteiner}>
                <div className={styles.logo}></div>
            </div>
            <div className={styles.panel}>
                <button className={started ? styles.hide : styles.playBtn} onClick={() => setStarted(true)}>START!</button>
                <div className={started ? styles.hide : styles.door}></div> 
                <div className={started ? styles.playingField : styles.hide}>
                {endOfgame && <div className={styles.endOfGame}>
                    <div className={styles.announcment}>{winnerAnnouncment}</div>
                    <button className={styles.onceAgain} onClick={restart}>Once again!</button>
                </div>}
                    <div className={backsideClass1}></div>
                    <div className={backsideClass2}></div>
                    <div className={backsideClass3}></div>
                    <div className={rockClass} onClick={() => play(0)}></div>
                    <div className={paperClass} onClick={() => play(1)}></div>
                    <div className={scissorsClass} onClick={() => play(2)}></div>
                </div>
            </div>
        </div>
    )
}