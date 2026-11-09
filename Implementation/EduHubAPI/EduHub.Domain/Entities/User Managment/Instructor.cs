using System;
using System.Collections.Generic;
using System.Text;
using EduHub.Domain.Entities.Course_Managment;

namespace EduHub.Domain.Entities.User_Managment
{
    public class Instructor : User
    {
        public int InstructorId { get; set; }
        public string Bio { get; set; } = string.Empty;
        public string Qualifications { get; set; } = string.Empty;
        public decimal Rating { get; set; }

        public User User { get; set; } = null!;
        public ICollection<Course> Courses { get; set; } = new List<Course>();
    }
}
