"use server";

import { OpaqueError, Result } from "@/lib/utils";

export async function reportNote(id: string): Promise<Result<null, string>> {
  const response = await fetch(`${process.env.API_URL}/report`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      id,
    }),
  });
  if (!response.ok) {
    const { error } = (await response.json()) as OpaqueError;
    return {
      ok: false,
      error,
    };
  }
  return {
    ok: true,
    result: null,
  };
}
