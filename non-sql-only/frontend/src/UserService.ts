import axios from 'axios';

interface User {
  id: number;
  email: string;
  firstName: string;
  lastName: string;
}

export class UserService {
  private apiUrl = 'http://localhost:8080/api/users';

  async getAllUsers(): Promise<User[]> {
    const response = await axios.get<User[]>(this.apiUrl);
    return response.data;
  }

  async getUserById(id: number): Promise<User> {
    const response = await axios.get<User>(`${this.apiUrl}/${id}`);
    return response.data;
  }

  async createUser(user: Omit<User, 'id'>): Promise<User> {
    const response = await axios.post<User>(this.apiUrl, user);
    return response.data;
  }

  async deleteUser(id: number): Promise<void> {
    await axios.delete(`${this.apiUrl}/${id}`);
  }
}
