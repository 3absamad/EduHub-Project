using EduHub.Domain.Entities.Transactions;
using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.User_Managment
{
    public class User
    {
        public int UserId { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public bool IsActive { get; set; } = true;

        public ICollection<UserRole> UserRoles { get; set; }= new List<UserRole>();
        public Student? StudentProfile { get; set; }
        public Instructor? InstructorProfile { get; set; }
        public ICollection<ForumPost> ForumPosts { get; set; } = new List<ForumPost>();
    }
}
