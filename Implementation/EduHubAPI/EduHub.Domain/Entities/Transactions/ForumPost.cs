using EduHub.Domain.Entities.User_Managment;
using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Transactions
{
    public class ForumPost
    {
        public int PostId { get; set; }
        public int ForumId { get; set; }
        public int UserId { get; set; }
        public string Message { get; set; } = string.Empty;
        public DateTime PostedAt { get; set; }

        public DiscussionForum Forum { get; set; } = null!;
        public User User { get; set; } = null!;
    }
}
