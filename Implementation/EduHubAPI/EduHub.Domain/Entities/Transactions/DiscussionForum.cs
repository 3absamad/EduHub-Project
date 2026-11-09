using EduHub.Domain.Entities.Course_Managment;
using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Transactions
{
    public class DiscussionForum
    {
        public int ForumId { get; set; }
        public int CourseId { get; set; }
        public string Topic { get; set; } = string.Empty;

        public Course Course { get; set; } = null!;
        public ICollection<ForumPost> Posts { get; set; }  = new List<ForumPost>();
    }
}
