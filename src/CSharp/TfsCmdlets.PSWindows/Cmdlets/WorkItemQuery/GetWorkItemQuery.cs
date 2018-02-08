using System.Management.Automation;
using Microsoft.TeamFoundation.WorkItemTracking.Client;

namespace TfsCmdlets.Cmdlets.WorkItemQuery
{
    [Cmdlet(VerbsCommon.Get, "WorkItemQuery")]
    [OutputType(typeof(QueryDefinition2))]
    public class GetWorkItemQuery : WorkItemQueryCmdletBase
    {
        protected override void ProcessRecord()
        {
            WriteObject(WorkItemQueryService.GetItems<QueryDefinition2>(Query, Scope, Project, Collection, Server, Credential), true);
        }

        [Parameter(Position = 0)]
        [ValidateNotNull]
        [SupportsWildcards]
        [Alias("Path")]
        public object Query { get; set; } = "**";

        [Parameter]
        public WorkItemQueryScope Scope { get; set; } = WorkItemQueryScope.Both;

        [Parameter(ValueFromPipeline = true)]
        public override object Project { get; set; }
    }
}
