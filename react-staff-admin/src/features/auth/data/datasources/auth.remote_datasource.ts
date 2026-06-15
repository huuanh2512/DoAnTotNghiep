import { apiClient } from '../../../../core/network/api_client';
import { AuthUserDTO } from '../models/auth.model';

export interface LoginResponse {
  success: boolean;
  accessToken: string;
  refreshToken: string;
  user: AuthUserDTO;
}

export class AuthRemoteDataSource {
  async login(email: string, password: string): Promise<LoginResponse> {
    const response = await apiClient.post<LoginResponse>('/auth/sign-in', {
      email,
      password,
    });
    return response.data;
  }
}
