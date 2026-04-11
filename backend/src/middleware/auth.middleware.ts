import { Request, Response, NextFunction } from "express";
import { getDataSource } from "../config/data-source";
import { jwtVerify } from "../config/jwt";
import { UserTokenQuery } from "../query/usertoken.query";
import { UserToken } from "../models/UserToken.entity";
import { ApiResponse } from "../utils/api.response";
import { runDailyVisitPlanning } from "../service/nodeCron.service";
import { getSupabaseServiceClient } from "../config/supabase";
import { User } from "../models/User.entity";

const userTokenQuery = new UserTokenQuery();

export const verifyToken = async (
  req: any,
  res: Response,
  next: NextFunction
): Promise<any> => {
  const token = req.headers["authorization"]?.split(" ")[1];
  if (req.url?.includes("/api/cron/daily-visit")) {
    try {
      await runDailyVisitPlanning();
      return res.status(200).json({ message: "Success" });
    } catch (err) {
      return ApiResponse.error(res, 500, "Internal Server Error");
    }
  }
  if (!token) {
    return ApiResponse.error(res, 401, "Token not provided");
  }

  // Try existing JWT verification first
  try {
    const decoded = await jwtVerify(token);

    // Check JWT timestamps for sanity
    const now = Math.floor(Date.now() / 1000);
    if (decoded.exp && decoded.exp < now) {
      return ApiResponse.error(res, 401, "Token expired");
    }

    let userToken;
    try {
      const dataSource = await getDataSource();
      const userTokenRepository = dataSource.getRepository(UserToken);
      userToken = await userTokenRepository.findOne({
        where: {
          user_token_id: token,
          user_id: decoded.user_id,
          is_active: true,
        },
      });
    } catch (dbError) {
      console.error("Database connection error during token lookup:", dbError);
      return ApiResponse.error(res, 500, "Database connection error");
    }

    if (!userToken) {
      console.log("User token not found in database:", {
        token: token.substring(0, 20) + "...",
        user_id: decoded.user_id,
      });
      return ApiResponse.error(res, 401, "Token not authorized");
    }

    const currentTime = Date.now();
    const tokenExpiryTime = userToken.created_at.getTime() + userToken.ttl;

    if (currentTime > tokenExpiryTime) {
      await userTokenQuery.deleteTokenFromDatabase(token);
      return ApiResponse.error(res, 401, "Token expired");
    }

    req.user = { ...decoded, token };
    next();
    return;
  } catch (jwtError) {
    // JWT verification failed – try Supabase token verification
  }

  // Try Supabase Auth token verification as fallback
  try {
    const supabase = getSupabaseServiceClient();
    const {
      data: { user: supabaseUser },
      error,
    } = await supabase.auth.getUser(token);

    if (error || !supabaseUser) {
      return ApiResponse.error(res, 401, "Token not authorized");
    }

    // Look up the app user by email from Supabase auth user
    const dataSource = await getDataSource();
    const userRepo = dataSource.getRepository(User);
    const appUser = await userRepo.findOne({
      where: { email: supabaseUser.email },
    });

    if (!appUser) {
      return ApiResponse.error(res, 401, "User not found in application");
    }

    if (!appUser.is_active) {
      return ApiResponse.error(res, 401, "User inactive");
    }

    req.user = {
      user_id: appUser.user_id,
      org_id: appUser.org_id,
      email: appUser.email,
      role_id: appUser.role_id,
      is_admin: appUser.is_admin,
      partner_id: appUser.partner_id,
      token,
    };
    next();
  } catch (supabaseError) {
    console.error("Supabase token verification failed:", supabaseError);
    return ApiResponse.error(res, 401, "Token not authorized");
  }
};
