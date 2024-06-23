import { create } from "zustand";

export type Store = {
  //   players: any; // { [id]: { player, vec }, [id2]: { player, vec } }
  //   update_player: (player: any) => void;
  player: any;
  update_player: (player: any) => void;
  tiles: any;
  update_tiles: (tile: any) => void;
};

export const useElementStore = create<Store>((set) => ({
  player: {},
  update_player: (player: any) =>
    set((state) => {
      return {
        player,
      };
    }),
  tiles: [],
  //   update_player: (player: any) =>
  //     set((state) => {
  //       return {
  //         players: {
  //           ...state.players,
  //           [player.player]: player,
  //         },
  //       };
  //     }),
  update_tiles: (tiles: any) =>
    set((state) => {
      return {
        tiles,
      };
    }),
}));
