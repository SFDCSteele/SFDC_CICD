public class CICDBuildDetailsWrapper {
 	public class BuildDetails {
        public String envName {get; set;}
        public String releaseNumber {get; set;}
        public String build_url {get; set;}
        public DateTime build_date {get; set;}
		public Integer build_id {get; set;}
		public String status {get; set;}
		public String project_name {get; set;}
		public String commit_id {get; set;}
		public String message {get; set;}
		public String committer {get; set;}
		public String branch {get; set;}
        public String errors {get; set;}
    }

    public class Build {
        public BuildDetails build {get; set;}
    }

    public List<Build> buildList {get; set;}

}