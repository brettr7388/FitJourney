declare module 'tokenStorage' {
    export interface JwtToken {
      accessToken: string;
    }
  
    export function storeToken(token: JwtToken): void;
    export function retrieveToken(): string | null;
  }
  