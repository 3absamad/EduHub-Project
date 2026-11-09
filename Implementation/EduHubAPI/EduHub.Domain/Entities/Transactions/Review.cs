using EduHub.Domain.Entities.Course_Managment;
using EduHub.Domain.Entities.User_Managment;
using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Transactions
{
    public class Review
    {
        public int ReviewId { get; set; }
        public int CourseId { get; set; }
        public int StudentId { get; set; }
        public int RatingValue { get; set; }
        public string Comment { get; set; } = string.Empty;
        public DateTime ReviewDate { get; set; }

        public Course Course { get; set; } = null!;
        public Student Student { get; set; } = null!;
    }
}
