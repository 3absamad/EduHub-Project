using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Course_Managment
{
    public class Category
    {
        public int CategoryId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;

        public ICollection<SubCategory> SubCategories { get; set; } = new List<SubCategory>();
    }
}
