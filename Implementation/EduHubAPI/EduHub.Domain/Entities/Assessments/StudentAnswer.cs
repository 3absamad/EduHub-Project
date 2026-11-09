using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Assessments
{
    public class StudentAnswer
    {
        public int AnswerId { get; set; }
        public int AttemptId { get; set; }
        public int QuestionId { get; set; }
        public int SelectedOptionId { get; set; }

        public QuizAttempt QuizAttempt { get; set; } = null!;
        public Question Question { get; set; } = null!;
        public QuestionOption SelectedOption { get; set; } = null!;
    }
}
