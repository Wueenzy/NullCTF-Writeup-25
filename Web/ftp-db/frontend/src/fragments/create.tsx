"use client";

import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Textarea } from "@/components/ui/textarea";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { z } from "zod";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import { createNote } from "@/actions/create";
import { ErrorFragment } from "@/fragments/error";
import { Result } from "@/lib/utils";
import { FileEdit } from "lucide-react";

const formSchema = z.object({
  content: z.string().min(1, {
    message: "Content must be at least 1 character",
  }),
});

export function CreateFragment() {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      content: "",
    },
  });

  const [result, setResult] = useState<Result<string, string> | null>(null);

  async function onSubmit(values: z.infer<typeof formSchema>) {
    const result = await createNote(values.content);
    setResult(result);
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-1">
              <FileEdit className="mr-2 h-4 w-4" />
              <div className="text-xl">Create new note</div>
            </CardTitle>
            <CardDescription>
              Enter the note&apos;s content, you will receive an UUID to access
              it later
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-5">
            <FormField
              name="content"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Content</FormLabel>
                  <FormControl>
                    <Textarea
                      className="min-h-[200px]"
                      placeholder="Note"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            {result ? (
              result.ok ? (
                <Alert className="bg-green-950 border-green-700">
                  <AlertDescription className="space-y-2 text-white">
                    <div className="font-medium">Your note ID:</div>
                    <div className="font-mono w-full p-2 text-sm bg-green-900 rounded border border-green-800">
                      {result.result}
                    </div>
                  </AlertDescription>
                </Alert>
              ) : (
                <ErrorFragment error={result.error} />
              )
            ) : null}
          </CardContent>
          <CardFooter>
            <Button className="w-full" type="submit">
              Create Note
            </Button>
          </CardFooter>
        </Card>
      </form>
    </Form>
  );
}
