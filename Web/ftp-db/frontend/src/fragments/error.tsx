import { Alert, AlertDescription } from "@/components/ui/alert";

export function ErrorFragment({ error }: { error: string }) {
  return (
    <Alert className="bg-red-950 border-red-700">
      <AlertDescription className="space-y-2 text-white">
        <div className="font-medium">Error</div>
        <div className="font-mono w-full p-2 text-sm bg-red-900 rounded border border-red-800">
          {error}
        </div>
      </AlertDescription>
    </Alert>
  );
}
