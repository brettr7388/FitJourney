export function buildPath(route: string): string {
    if (import.meta.env.MODE === 'development') {
      return `http://localhost:5001/${route}`;
    } else {
      return `https://api.fitjourneyhome.com/${route}`;
    }
  }
  