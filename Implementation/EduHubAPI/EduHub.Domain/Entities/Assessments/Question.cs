using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Assessments
{
    public class Question
    {
        public int QuestionId { get; set; }
        public int QuizId { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public string QuestionType { get; set; } = string.Empty;
        public int Points { get; set; }

        public Quiz Quiz { get; set; } = null!;
        public ICollection<QuestionOption> Options { get; set; } = new List<QuestionOption>();
        public ICollection<StudentAnswer> StudentAnswers { get; set; }  = new List<StudentAnswer>();
    }
}
