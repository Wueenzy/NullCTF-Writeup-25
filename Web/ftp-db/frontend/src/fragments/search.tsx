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
import { Input } from "@/components/ui/input";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { z } from "zod";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useEffect, useState } from "react";
import { retrieveNote } from "@/actions/retrieve";
import { ErrorFragment } from "@/fragments/error";
import { Result } from "@/lib/utils";
import { Search } from "lucide-react";
import { useSearchParams } from "next/navigation";
import { reportNote } from "@/actions/report";

const formSchema = z.object({
  id: z.string().min(1, {
    message: "Content must be at least 1 character",
  }),
});

export function SearchFragment() {
  const searchParams = useSearchParams();
  const queryId = searchParams.get("id");

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      id: queryId ?? "",
    },
  });

  const [reportResult, setReportResult] = useState<Result<null, string> | null>(
    null,
  );
  const [searchResult, setSearchResult] = useState<Result<
    string,
    string
  > | null>(null);
  const [isReporting, setIsReporting] = useState(false);

  async function onSubmit(values: z.infer<typeof formSchema>) {
    const result = await retrieveNote(values.id);
    setSearchResult(result);
  }

  async function reportToAdmin(id: string) {
    setIsReporting(true);
    const result = await reportNote(id);
    setReportResult(result);
    setIsReporting(false);
  }

  useEffect(() => {
    if (queryId) {
      onSubmit({
        id: queryId,
      }).then();
    }
  }, [queryId]);

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-1">
              <Search className="mr-2 h-4 w-4" />
              <div className="text-xl">Search note</div>
            </CardTitle>
            <CardDescription>
              Enter the note&apos;s ID to fetch its content
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-5">
            <FormField
              name="id"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>ID</FormLabel>
                  <FormControl>
                    <Input placeholder="ID" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            {searchResult ? (
              searchResult.ok ? (
                <Alert className="bg-green-950 border-green-700">
                  <AlertDescription className="space-y-2 text-white">
                    <div className="font-medium">Your note&apos;s content:</div>
                    <div
                      className="font-mono w-full p-2 text-sm bg-green-900 rounded border border-green-800"
                      dangerouslySetInnerHTML={{
                        __html: searchResult.result,
                      }}
                    />
                    <Button
                      className="w-full bg-red-300"
                      onClick={() => reportToAdmin(form.getValues("id"))}
                      disabled={isReporting}
                    >
                      {isReporting ? "Reporting..." : "Report to Admin"}
                    </Button>
                    {reportResult
                      ? reportResult.ok
                        ? "Reported successfully"
                        : reportResult.error
                      : null}
                  </AlertDescription>
                </Alert>
              ) : (
                <ErrorFragment error={searchResult.error} />
              )
            ) : null}
          </CardContent>
          <CardFooter>
            <Button className="w-full" type="submit">
              Search Note
            </Button>
          </CardFooter>
        </Card>
      </form>
    </Form>
  );
}
