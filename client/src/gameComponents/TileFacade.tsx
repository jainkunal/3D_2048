import * as THREE from "three";
import { useMemo } from "react";
import { MAP_SCALE } from "@/config";

export const Tile = ({ position }: any) => {
    const squareGeometry = useMemo(
        () => new THREE.BoxGeometry(MAP_SCALE, MAP_SCALE, MAP_SCALE),
        [MAP_SCALE]
    );

    return (
        <>
            <mesh
                // receiveShadow
                position={[position.x, -position.z, position.y]}
                geometry={squareGeometry}
                material={
                    new THREE.MeshPhongMaterial({
                        color: "lightgrey",
                        transparent: true,
                        opacity: 0.1
                    })
                }
            ></mesh>
            <lineSegments
                geometry={new THREE.EdgesGeometry(squareGeometry)}
                material={
                    new THREE.LineBasicMaterial({
                        color: "black",
                        linewidth: 1,
                    })
                }
                position={[position.x, -position.z + 0.01, position.y]}
            />
        </>
    );
};
