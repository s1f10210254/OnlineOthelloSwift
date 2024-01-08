import server from "$/$server";
import { API_BASE_PATH, CORS_ORIGIN } from "$/service/envValues";
import cookie from "@fastify/cookie";
import cors from "@fastify/cors";
import helmet from "@fastify/helmet";
import type { FastifyServerFactory } from "fastify";
import Fastify from "fastify";
import { prismaClient } from "./prismaClient";
import {
  createNewGmeSession,
  updateGameBoard,
} from "$/repository/othelloRepository";

export const init = (serverFactory?: FastifyServerFactory) => {
  const app = Fastify({ serverFactory });
  app.register(helmet);
  app.register(cors, { origin: CORS_ORIGIN, credentials: true });
  app.register(cookie);
  server(app, { basePath: API_BASE_PATH });

  app.post("/search-game", async (request, reply) => {
    const { roomKey } = request.body as { roomKey: string };
    try {
      const game = await prismaClient.game.findFirst({
        where: { room: roomKey },
      });

      if (!game) {
        return reply.status(404).send({ message: "ゲームが見つかりません" });
      }
      console.log(game);
      return reply.send({
        gameId: game.id,
        board: game.board,
        turn: game.turn,
      });
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ message: "サーバーエラー" });
    }
  });

  app.post("/start-game", async (request, reply) => {
    const gameSession = createNewGmeSession();

    return reply.send({
      gameId: (await gameSession).id,
      board: (await gameSession).board,
      turn: (await gameSession).turn,
    });
  });

  interface GameMove {
    gameId: number;
    x: number;
    y: number;
    turn: number;
  }
  // 送信されたてを処理し、ゲームの状態を更新
  app.post("/make-move", async (request, reply) => {
    const { gameId, x, y, turn } = request.body as GameMove;
    const game = await prismaClient.game.findUnique({
      where: { id: gameId },
    });
    if (!game || !Array.isArray(game.board)) {
      return reply.status(404).send({ message: "ゲームが見つかりません" });
    }
    const currentBoard = game.board as number[][];
    const updatedBoard = updateGameBoard(currentBoard, x, y, turn);

    const updatedGame = await prismaClient.game.update({
      where: { id: gameId },
      data: { board: updatedBoard, turn: turn === 1 ? 2 : 1 },
    });
    console.log(updatedGame.turn);
    return reply.send({
      gameId: gameId,
      board: updatedGame.board,
      turn: updatedGame.turn,
    });
  });
  return app;
};
