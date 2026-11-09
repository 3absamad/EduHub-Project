using EduHub.Domain.Entities.Transactions;
using EduHub.Domain.Entities.User_Managment;
using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Course_Managment
{
    public class Course
    {
        public int CourseId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public string Level { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public int InstructorId { get; set; }
        public int SubCategoryId { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public Instructor Instructor { get; set; } = null!;
        public SubCategory SubCategory { get; set; } = null!;
        public ICollection<Module> Modules { get; set; } = new List<Module>();
        public ICollection<CourseTag> CourseTags { get; set; } = new List<CourseTag>();
        public ICollection<Enrollment> Enrollments { get; set; } = new List<Enrollment>();
        public ICollection<DiscussionForum> DiscussionForums { get; set; } = new List<DiscussionForum>();
        public ICollection<Review> Reviews { get; set; } = new List<Review>();
    }
}
