// api/index.ts
import express, { Response } from "express";
import "reflect-metadata";
import expressSession from "express-session";
import router from "../src/routes/index.route";
import cors from "cors";
import { verifyToken } from "../src/middleware/auth.middleware";
import { UserTeamController } from "../src/controllers/user.controller";
import { regionsData } from "../src/data/regions";

const userController = new UserTeamController();
const app = express();

app.use(cors({
  origin: true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
}));
app.use(
  expressSession({
    secret: "your-secret-key",
    resave: false,
    saveUninitialized: false,
  })
);
app.use(express.json());
app.use("/api", router);
app.use(verifyToken);
app.use("/", (req, res) => {
  res.send("Welcome to track");
});
app.get("/api/user/me", userController.getUserById);

// Global error handler to prevent unhandled promise rejections from hanging requests
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error("Unhandled error:", err);
  res.status(500).json({ success: false, error: { message: "Internal server error" } });
});

export default app;