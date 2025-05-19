export interface JwtToken {
    accessToken: string;
  }
  
  export function storeToken(tok: JwtToken): void {
    try {
      localStorage.setItem('token_data', tok.accessToken);
    } catch (e: unknown) {
      if (e instanceof Error) {
        console.log(e.message);
      } else {
        console.log('Unknown error in storeToken');
      }
    }
  }
  
  export function retrieveToken(): string | null {
    let ud: string | null = null;
    try {
      ud = localStorage.getItem('token_data');
    } catch (e: unknown) {
      if (e instanceof Error) {
        console.log(e.message);
      } else {
        console.log('Unknown error in retrieveToken');
      }
    }
    return ud;
  }
  