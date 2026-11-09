using EduHub.Domain.Entities.User_Managment;
using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Assessments
{
    public class QuizAttempt
    {
        public int AttemptId { get; set; }
        public int QuizId { get; set; }
        public int StudentId { get; set; }
        public DateTime AttemptDate { get; set; }
        public int Score { get; set; }
        public bool IsPassed { get; set; }

        public Quiz Quiz { get; set; } = null!;
        public Student Student { get; set; } = null!;
        public ICollection<StudentAnswer> StudentAnswers { get; set; } = new List<StudentAnswer>();
    }
}
