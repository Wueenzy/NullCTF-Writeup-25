"use server";

import { OpaqueError, Result } from "@/lib/utils";

type Response = {
  content: string;
};

export async function retrieveNote(
  id: string,
): Promise<Result<string, string>> {
  const response = await fetch(`${process.env.API_URL}/retrieve/${id}`);
  if (!response.ok) {
    const { error } = (await response.json()) as OpaqueError;
    return {
      ok: false,
      error,
    };
  }
  const { content } = (await response.json()) as Response;
  return {
    ok: true,
    result: content,
  };
}
