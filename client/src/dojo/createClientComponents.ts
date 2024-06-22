import { overridableComponent } from "@dojoengine/recs";
import { ContractComponents } from "./generated/contractComponents";

export type ClientComponents = ReturnType<typeof createClientComponents>;

export function createClientComponents({
  contractComponents,
}: {
  contractComponents: ContractComponents;
}) {
  return {
    ...contractComponents,
    Player: overridableComponent(contractComponents.Player),
    Game: overridableComponent(contractComponents.Game),
    Tile: overridableComponent(contractComponents.Tile),
  };
}
