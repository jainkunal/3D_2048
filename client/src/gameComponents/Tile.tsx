import * as THREE from "three";
import { useDojo } from "@/dojo/useDojo";
import { useComponentValue } from "@dojoengine/react";
import { RoundedBox, Text } from "@react-three/drei";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { Direction } from "@/utils";
import { useEffect, useMemo, useRef, useState } from "react";
import { useFrame } from "@react-three/fiber";
import { MAP_SCALE } from "@/config";

export const TileComponent = (props: any) => {
    const {
        account: { account },
        setup: {
            clientComponents: { Game, Tile },
            systemCalls: { move },
        },
    } = useDojo();

    const [hoveredTile, setHoveredTile] = useState<Direction | undefined>(
        undefined
    );
    const [startPosition, setStartPosition] = useState<
        THREE.Vector3 | undefined
    >();
    let targetPosition = useRef<THREE.Vector3 | undefined>();

    // Retrieve player info
    const { tileId } = props;

    const tile = useComponentValue(Tile, tileId);

    // Retrieve local player
    // const localPlayer = useComponentValue(
    //     Game,
    //     getEntityIdFromKeys([BigInt(account.address), BigInt(1)])
    // );

    // const handleTileClick = (direction: Direction) => {
    //     move(account, 1, direction);
    // };

    const isLocalPlayer = true;

    const vec = {
        x: tile.x,
        y: tile.y
    }
    const color = isLocalPlayer ? "green" : "red";

    // Blue cell around player
    const squareGeometry = useMemo(
        () => new THREE.BoxGeometry(MAP_SCALE, MAP_SCALE, MAP_SCALE),
        [MAP_SCALE]
    );

    // Progress ref
    const lerpProgress = useRef(0);
    const boxRef: any = useRef();
    const textRef: any = useRef();

    // Lerp
    useFrame((_, delta) => {
        if (!startPosition || !targetPosition.current) return;
        if (lerpProgress.current < 1) {
            lerpProgress.current += delta * 4; // Adjust this value for speed

            if (boxRef.current) {
                boxRef.current.position.lerpVectors(
                    startPosition,
                    targetPosition.current,
                    lerpProgress.current
                );
            }
            if (textRef.current) {
                textRef.current.position.lerpVectors(
                    startPosition.clone().add(new THREE.Vector3(0, 0.6, 0)),
                    targetPosition.current.clone().add(new THREE.Vector3(0, 0.6, 0)),
                    lerpProgress.current
                );
            }
        } else if (lerpProgress.current >= 1) {
            boxRef.current.position.copy(targetPosition.current);
            if (textRef.current) {
                textRef.current.position.copy(targetPosition.current.clone().add(new THREE.Vector3(0, 0.6, 0)));
            }
        }
    });

    // When a new position is set, start lerp
    useEffect(() => {
        const newTargetPosition = new THREE.Vector3(
            vec.y * MAP_SCALE,
            0,
            vec.x * MAP_SCALE
        );

        // Check if there is an existing target position
        if (targetPosition.current) {
            // Set the start position to the current target position for the lerp
            setStartPosition(targetPosition.current);
        } else {
            // If it's the first time, just set the cone's position directly
            if (boxRef.current) {
                boxRef.current.position.copy(newTargetPosition);
            }
            if (textRef.current) {
                textRef.current.position.copy(newTargetPosition.clone().add(new THREE.Vector3(0, 0.6, 0)));
            }
        }

        targetPosition.current = newTargetPosition;
        lerpProgress.current = 0;

        // Reset Hovered Tile
        setHoveredTile(undefined);
    }, [boxRef, textRef, tile, vec.x, vec.y]);

    useEffect(() => {
        // Change cursor style if hovering a tile
        document.body.style.cursor = hoveredTile ? "pointer" : "default";
    }, [hoveredTile]);

    return (
        <>
            <RoundedBox
                key="player"
                ref={boxRef}
                scale={[MAP_SCALE, MAP_SCALE / 50, MAP_SCALE]}
                material={new THREE.MeshPhongMaterial({ color })}
            />
            <Text
                ref={textRef}
                position={targetPosition.current?.clone().add(new THREE.Vector3(0, 0.6, 0))}
                fontSize={20}
                color="black"
                rotation={[-Math.PI / 2, 0, 0]}
            >
                {tile.value}
            </Text>
        </>
    );
};
