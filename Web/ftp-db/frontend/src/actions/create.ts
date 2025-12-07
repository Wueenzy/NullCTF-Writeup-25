"use server";

import { OpaqueError, Result } from "@/lib/utils";

type Response = {
  id: string;
};

export async function createNote(
  content: string,
): Promise<Result<string, string>> {
  const response = await fetch(`${process.env.API_URL}/store`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      content,
    }),
  });
  if (!response.ok) {
    const { error } = (await response.json()) as OpaqueError;
    return {
      ok: false,
      error,
    };
  }
  const { id } = (await response.json()) as Response;
  return {
    ok: true,
    result: id,
  };
}
