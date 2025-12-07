import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export type OpaqueError = {
  error: string;
};

export type Result<T, E> =
  | {
      ok: true;
      result: T;
    }
  | {
      ok: false;
      error: E;
    };
