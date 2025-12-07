import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { CreateFragment } from "@/fragments/create";
import { SearchFragment } from "@/fragments/search";
import Link from "next/link";
import { FC, ReactElement, Suspense } from "react";
import { FileEdit, Search } from "lucide-react";

export default function DashboardFragment({
  initialTab,
}: {
  initialTab: string;
}) {
  function createTab(
    name: string,
    Icon: FC<{
      className: string;
    }>,
  ): ReactElement {
    return (
      <TabsTrigger value={name}>
        <Link className="w-full flex justify-center" href={`/${name}`}>
          <div className="flex items-center gap-1">
            <Icon className="mr-2 h-4 w-4" />
            {name[0].toUpperCase() + name.slice(1)}
          </div>
        </Link>
      </TabsTrigger>
    );
  }

  return (
    <div className="container mx-auto py-10">
      <Tabs value={initialTab}>
        <TabsList className="w-full grid grid-cols-2">
          {createTab("create", FileEdit)}
          {createTab("search", Search)}
        </TabsList>
        <TabsContent value="create">
          <CreateFragment />
        </TabsContent>
        <TabsContent value="search">
          <Suspense>
            <SearchFragment />
          </Suspense>
        </TabsContent>
      </Tabs>
    </div>
  );
}
