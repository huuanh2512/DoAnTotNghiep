import { io, Socket } from 'socket.io-client';
import { authStorage } from '../utils/auth_storage';

class SocketService {
  private socket: Socket | null = null;
  private isConnecting: boolean = false;

  connect(
    onNotificationReceived: (notification: any) => void,
    onBookingCreated: (bookingData: any) => void
  ) {
    if (this.socket?.connected || this.isConnecting) return;

    const token = authStorage.getAccessToken();
    const user = authStorage.getUser();
    if (!token || !user) return;

    this.isConnecting = true;
    const apiUrl = process.env.REACT_APP_API_URL || 'http://localhost:3000/api/v1';
    // Deduce Socket base URL from API URL (e.g., http://localhost:3000)
    const socketUrl = apiUrl.replace(/\/api\/v1\/?$/, '') || 'http://localhost:3000';

    console.log(`[Socket] Connecting to Socket.IO Server at ${socketUrl}...`);

    this.socket = io(socketUrl, {
      auth: { token },
      transports: ['websocket'],
      query: { token } // Support fallback handshake query
    });

    this.socket.on('connect', () => {
      console.log('[Socket] Connected successfully!');
      this.isConnecting = false;

      // Join rooms
      if (user.role === 'STAFF') {
        this.socket?.emit('join_room', 'room_staff');
        console.log('[Socket] Joined room_staff');
      }
      this.socket?.emit('join_room', `user_${user._id}`);
      console.log(`[Socket] Joined user_${user._id}`);
    });

    this.socket.on('booking_created', (data) => {
      console.log('[Socket] Received booking_created:', data);
      onBookingCreated(data);
    });

    this.socket.on('new_notification', (data) => {
      console.log('[Socket] Received new_notification:', data);
      onNotificationReceived(data);
    });

    this.socket.on('connect_error', (error) => {
      console.error('[Socket] Connection error:', error);
      this.isConnecting = false;
    });

    this.socket.on('disconnect', (reason) => {
      console.log('[Socket] Disconnected:', reason);
      this.isConnecting = false;
    });
  }

  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
      this.isConnecting = false;
      console.log('[Socket] Disconnected from server manually.');
    }
  }
}

export const socketService = new SocketService();
